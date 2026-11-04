import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/image_demande.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart'; // adapte au nom réel de ton fichier

class ImageDemandeRepository {
  static String get baseUrl => '${AuthRepository.baseUrl}/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  final http.Client _client;

  ImageDemandeRepository(this._client);

  Future<List<ImageDemande>> getImagesDemande(int demandeId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/images-demandes/demande/$demandeId'),
      headers: await _headers(),
    );

    debugPrint('IMAGES demande $demandeId : ${response.statusCode} ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les images (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException('La réponse doit être une liste JSON.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => ImageDemande.fromJson(json))
        .toList();
  }

  Future<ImageDemande> getImageById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/images-demandes/$id'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer l’image (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'La réponse doit être un objet JSON.',
      );
    }

    return ImageDemande.fromJson(decoded);
  }
}

final imageDemandeRepositoryProvider = Provider<ImageDemandeRepository>((ref) {
  return ImageDemandeRepository(ref.watch(httpClientProvider));
});

// Les autres providers restent identiques
final imagesDemandeProvider =
FutureProvider.family<List<ImageDemande>, int>((ref, demandeId) {
  return ref.watch(imageDemandeRepositoryProvider).getImagesDemande(demandeId);
});

final imageDemandeDetailProvider =
FutureProvider.family<ImageDemande, int>((ref, id) {
  return ref.watch(imageDemandeRepositoryProvider).getImageById(id);
});