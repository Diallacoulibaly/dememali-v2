import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/donateur.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

final donateurRepositoryProvider = Provider<DonateurRepository>((ref) {
  return DonateurRepository(
    baseUrl: AuthRepository.apiUrl,
    client: ref.watch(httpClientProvider),
  );
});

final donateurProvider =
FutureProvider.family<Donateur, int>((ref, id) {
  return ref.watch(donateurRepositoryProvider).getById(id);
});

final tousLesDonateursProvider =
FutureProvider<List<Donateur>>((ref) {
  return ref.watch(donateurRepositoryProvider).getAll();
});

class DonateurRepository {
  static String get baseUrl => AuthRepository.apiUrl;
  final String _instanceBaseUrl;
  final http.Client? client;
  final FlutterSecureStorage stockage = const FlutterSecureStorage();

  DonateurRepository({
    String? baseUrl,
    this.client,
  }) : _instanceBaseUrl = baseUrl ?? AuthRepository.apiUrl;

  String get effectiveBaseUrl => _instanceBaseUrl;

  Future<Donateur> getById(int id) async {
    final response = await _get('/donateurs/$id');
    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Donateur>> getAll() async {
    final response = await _get('/donateurs');

    if (response is! List) {
      throw const FormatException(
        'La réponse doit être une liste de donateurs.',
      );
    }

    return response.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Un donateur reçu est invalide.',
        );
      }

      return Donateur.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<Donateur> modifierPays({
    required int donateurId,
    required int paysId,
  }) async {
    final response = await _request(
      'PATCH',
      '/donateurs/$donateurId/pays/$paysId',
    );

    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  Future<Donateur> creer(Map<String, dynamic> donnees) async {
    final response = await _request(
      'POST',
      '/donateurs',
      body: donnees,
    );

    return Donateur.fromJson(response as Map<String, dynamic>);
  }

  // Inscription d'un donateur : POST /api/donateurs
  // Corps attendu (DonateurRequestDTO) : nom, prenom, telephone,
  // motDePasse, sexe (MASCULIN | FEMININ), paysId.
  Future<void> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String sexe,
    required int paysId,
  }) async {
    final corpsEnvoi = jsonEncode({
      'nom': nom.trim(),
      'prenom': prenom.trim(),
      'telephone': telephone,
      'motDePasse': motDePasse,
      'sexe': sexe,
      'paysId': paysId,
    });

    final reponse = await http
        .post(
          Uri.parse('$effectiveBaseUrl/donateurs'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: corpsEnvoi,
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('Délai d’attente dépassé avec le serveur.'),
        );

    if (reponse.statusCode == 201 || reponse.statusCode == 200) {
      return;
    }

    if (reponse.statusCode == 500) {
      throw Exception('Ce numéro de téléphone est déjà associé à un compte ou les données saisies sont invalides.');
    }

    try {
      final corps = jsonDecode(utf8.decode(reponse.bodyBytes));
      if (corps is Map<String, dynamic>) {
        if (corps['message'] is String && (corps['message'] as String).isNotEmpty) {
          throw Exception(corps['message']);
        }
        if (corps['error'] is String && (corps['error'] as String).isNotEmpty) {
          final detail = corps['trace'] ?? corps['message'] ?? corps['error'];
          throw Exception('${corps['error']} (${reponse.statusCode}) : $detail');
        }
      }
    } on FormatException {
      // Le corps n'est pas du JSON
    }

    throw Exception('Erreur HTTP ${reponse.statusCode} : ${reponse.body}');
  }

  /// Sauvegarder la photo de profil du donateur (POST multipart /api/utilisateurs/{id}/photo)
  Future<bool> enregistrerPhotoProfil({
    required int donateurId,
    required String cheminFichier,
  }) async {
    try {
      await stockage.write(key: 'userPhotoPath_$donateurId', value: cheminFichier);
      await stockage.write(key: 'userPhotoPath', value: cheminFichier);

      final token = await stockage.read(key: 'accessToken');
      final uri = Uri.parse('$effectiveBaseUrl/utilisateurs/$donateurId/photo');
      final req = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';
      req.files.add(await http.MultipartFile.fromPath('photo', cheminFichier));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final nomPhoto = data['nomFichier'] ?? data['photo'] ?? data['url'];
        if (nomPhoto != null) {
          await stockage.write(
            key: 'userPhotoPath_$donateurId',
            value: nomPhoto.toString(),
          );
          await stockage.write(
            key: 'userPhotoPath',
            value: nomPhoto.toString(),
          );
        }
        return true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Supprimer la photo de profil du donateur (DELETE /api/utilisateurs/{id}/photo)
  Future<void> supprimerPhotoProfil(int donateurId) async {
    await stockage.delete(key: 'userPhotoPath_$donateurId');
    await stockage.delete(key: 'userPhotoPath');
    try {
      final token = await stockage.read(key: 'accessToken');
      final uri = Uri.parse('$effectiveBaseUrl/utilisateurs/$donateurId/photo');
      await http.delete(uri, headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
    } catch (_) {}
  }

  /// Récupérer le chemin local ou nom de photo mis en cache
  Future<String?> obtenirPhotoProfil(int donateurId) async {
    return (await stockage.read(key: 'userPhotoPath_$donateurId')) ??
        (await stockage.read(key: 'userPhotoPath'));
  }

  Future<dynamic> _get(String path) async {
    return _request('GET', path);
  }

  Future<dynamic> _request(
      String method,
      String path, {
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$effectiveBaseUrl$path');
    final cl = client ?? http.Client();

    try {
      final token = await stockage.read(key: 'accessToken');
      final baseHeaders = <String, String>{
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await cl.get(
            url,
            headers: baseHeaders,
          ).timeout(const Duration(seconds: 15));
          break;

        case 'POST':
          response = await cl.post(
            url,
            headers: {
              ...baseHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          ).timeout(const Duration(seconds: 15));
          break;

        case 'PATCH':
          response = await cl.patch(
            url,
            headers: baseHeaders,
          ).timeout(const Duration(seconds: 15));
          break;

        default:
          throw UnsupportedError('Méthode HTTP non prise en charge.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Erreur API ${response.statusCode} : ${response.body}',
        );
      }

      if (response.body.trim().isEmpty) {
        return null;
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception('Le serveur ne répond pas à temps.');
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion : ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Réponse JSON invalide : ${e.message}');
    }
  }
}
