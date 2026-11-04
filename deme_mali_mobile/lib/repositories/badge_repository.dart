import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/badge_donateur_model.dart';
import 'auth_repository.dart';

class BadgeRepository {
  final http.Client client;
  final String baseUrl;
  final FlutterSecureStorage stockage;

  BadgeRepository({
    required this.client,
    required this.baseUrl,
    this.stockage = const FlutterSecureStorage(),
  });

  /// Récupérer les badges du semestre actuel.
  Future<List<BadgeDonateurModel>> obtenirBadgesActuels(
    int donateurId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/badges/donateur/$donateurId/actuel',
    );

    return _envoyerRequete(url);
  }

  /// Récupérer les badges d'un semestre précis.
  Future<List<BadgeDonateurModel>> obtenirBadgesSemestre({
    required int donateurId,
    required int annee,
    required String semestre,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/badges/donateur/$donateurId',
    ).replace(
      queryParameters: {
        'annee': annee.toString(),
        'semestre': semestre,
      },
    );

    return _envoyerRequete(url);
  }

  /// Récupérer l'historique des badges.
  Future<List<BadgeDonateurModel>> obtenirHistorique(
    int donateurId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/badges/donateur/$donateurId/historique',
    );

    return _envoyerRequete(url);
  }

  /// Exécuter une requête HTTP et convertir le JSON.
  Future<List<BadgeDonateurModel>> _envoyerRequete(
    Uri url,
  ) async {
    try {
      final token = await stockage.read(key: 'accessToken');
      final headers = <String, String>{
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await client
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[BADGES] Requête : $url (Token présent: ${token != null && token.isNotEmpty}) -> HTTP ${response.statusCode}');
      debugPrint('[BADGES] Corps réponse : ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur HTTP ${response.statusCode} : ${response.body}',
        );
      }

      final dynamic donnees = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List liste;
      if (donnees is List) {
        liste = donnees;
      } else if (donnees is Map && donnees['content'] is List) {
        liste = donnees['content'] as List;
      } else if (donnees is Map && donnees['badges'] is List) {
        liste = donnees['badges'] as List;
      } else if (donnees is Map && donnees['donnees'] is List) {
        liste = donnees['donnees'] as List;
      } else if (donnees is Map && donnees['data'] is List) {
        liste = donnees['data'] as List;
      } else {
        throw const FormatException(
          'La réponse du serveur doit être une liste JSON ou contenir un tableau.',
        );
      }

      return liste.map<BadgeDonateurModel>((element) {
        if (element is! Map) {
          throw const FormatException(
            'Un élément de badge est invalide.',
          );
        }

        return BadgeDonateurModel.fromJson(
          Map<String, dynamic>.from(element),
        );
      }).toList();
    } on TimeoutException {
      throw Exception(
        'Délai dépassé. Vérifie que le backend est démarré.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Connexion au serveur impossible : ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Réponse JSON invalide : ${e.message}',
      );
    }
  }
}

/// Client HTTP partagé par les repositories.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Repository des badges.
final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final client = ref.watch(httpClientProvider);

  return BadgeRepository(
    client: client,
    baseUrl: AuthRepository.baseUrl,
  );
});

