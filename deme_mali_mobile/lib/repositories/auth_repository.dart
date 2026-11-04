import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/reponse_connexion.dart';
import 'session_expiration.dart';

class AuthRepository {
  // Adresse du backend Spring Boot (h�te racine : localhost sur Web/Desktop, 10.0.2.2 sur �mulateur Android)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  // URL de base de l'API REST
  static String get apiUrl => '$baseUrl/api';

  // Stockage du token
  final FlutterSecureStorage stockage = const FlutterSecureStorage();

  // Connexion de l'utilisateur
  Future<ReponseConnexion> connexion({
    required String telephone,
    required String motDePasse,
  }) async {
final url = Uri.parse('$apiUrl/auth/login');
    final chrono = Stopwatch()..start();

    // Normaliser le numéro : supprimer tous les espaces
    final telNettoye = telephone.replaceAll(RegExp(r'\s+'), '');

    try {
      debugPrint('[CONNEXION] Envoi de la requete pour $telNettoye...');

      http.Response reponse = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'telephone': telNettoye,
          'motDePasse': motDePasse,
        }),
      )
          .timeout(const Duration(seconds: 15));

      // Si echec 403 et que le numero commence par +223, essayer sans +223
      if (reponse.statusCode == 403 && telNettoye.startsWith('+223')) {
        final telSansIndicatif = telNettoye.replaceFirst('+223', '');
        debugPrint('[CONNEXION] Nouvelle tentative sans indicatif : $telSansIndicatif');
        try {
          final reponse2 = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'telephone': telSansIndicatif,
              'motDePasse': motDePasse,
            }),
          ).timeout(const Duration(seconds: 10));
          if (reponse2.statusCode == 200) {
            reponse = reponse2;
          }
        } catch (_) {}
      } else if (reponse.statusCode == 403 && !telNettoye.startsWith('+') && telNettoye.length == 8) {
        // Inversement, si le numero a 8 chiffres, essayer avec +223
        final telAvecIndicatif = '+223$telNettoye';
        debugPrint('[CONNEXION] Nouvelle tentative avec indicatif : $telAvecIndicatif');
        try {
          final reponse2 = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'telephone': telAvecIndicatif,
              'motDePasse': motDePasse,
            }),
          ).timeout(const Duration(seconds: 10));
          if (reponse2.statusCode == 200) {
            reponse = reponse2;
          }
        } catch (_) {}
      }

      debugPrint(
        '[CONNEXION] Reponse HTTP recue (${reponse.statusCode}) : '
            '${chrono.elapsedMilliseconds} ms',
      );

      if (reponse.statusCode == 403 || reponse.statusCode == 401) {
        try {
          final donneesErreur = jsonDecode(reponse.body);
          if (donneesErreur is Map && donneesErreur['message'] != null) {
            final msg = donneesErreur['message'].toString().trim();
            if (msg.isNotEmpty && !msg.toLowerCase().contains('bad credentials')) {
              throw Exception(msg);
            }
          }
        } catch (e) {
          if (e is Exception && !e.toString().toLowerCase().contains('bad credentials')) {
            rethrow;
          }
        }
        throw Exception('Numéro de téléphone ou mot de passe incorrect.');
      }

      if (reponse.statusCode != 200) {
        String msg = 'Erreur serveur (${reponse.statusCode})';
        try {
          final donneesErreur = jsonDecode(reponse.body);
          if (donneesErreur is Map && donneesErreur['message'] != null) {
            final extrait = donneesErreur['message'].toString().trim();
            if (extrait.isNotEmpty) {
              msg = extrait;
            }
          }
        } catch (_) {}
        throw Exception(msg);
      }

      // Lire la reponse du backend
      final donnees = jsonDecode(reponse.body) as Map<String, dynamic>;

      // Convertir la reponse en objet Flutter
      final resultat = ReponseConnexion.fromJson(donnees);

      debugPrint(
        '[CONNEXION] JSON analyse : '
            '${chrono.elapsedMilliseconds} ms',
      );

      // Enregistrer le token recu
      await stockage.write(
        key: 'accessToken',
        value: resultat.accessToken,
      ).timeout(const Duration(seconds: 5));

      await stockage.write(
        key: 'userId',
        value: resultat.utilisateur.id.toString(),
      );
      await stockage.write(
        key: 'userPrenom',
        value: resultat.utilisateur.prenom,
      );
      await stockage.write(
        key: 'userNom',
        value: resultat.utilisateur.nom,
      );
      await stockage.write(
        key: 'userTelephone',
        value: resultat.utilisateur.telephone,
      );
      await stockage.write(
        key: 'userRole',
        value: resultat.utilisateur.role,
      );

      SessionExpiration.surveiller(resultat.accessToken);

      return resultat;
    } on SocketException {
      debugPrint('[CONNEXION] Erreur Socket (serveur inaccessible)');
      throw Exception(
        'Impossible de joindre le serveur ($baseUrl). '
        'Verifiez que votre telephone et votre ordinateur sont sur le meme reseau Wi-Fi.',
      );
    } on TimeoutException {
      debugPrint('[CONNEXION] Delai depasse.');
      throw Exception(
        'La connexion prend trop de temps. '
        'Verifiez que le serveur est demarre et joignable sur $apiUrl.',
      );
    } catch (e) {
      debugPrint('[CONNEXION] Erreur : $e');
      rethrow;
    } finally {
      chrono.stop();
      debugPrint(
        '[CONNEXION] Duree totale : '
            '${chrono.elapsedMilliseconds} ms',
      );
    }
  }

  // Recuperer le token enregistre
  Future<String?> recupererToken() async {
    return stockage.read(key: 'accessToken');
  }

  // Deconnexion : supprimer les donnees de session
  Future<void> deconnexion() async {
    SessionExpiration.arreter();
    await stockage.deleteAll();
  }
}
