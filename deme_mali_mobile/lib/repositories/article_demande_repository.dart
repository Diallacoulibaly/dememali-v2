import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/article_demande.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart'; // adapte au nom réel de ton fichier

class ArticleDemandeRepository {
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

  ArticleDemandeRepository([http.Client? client]) : _client = client ?? http.Client();

  // Récupérer les articles initiaux d'une demande.
  Future<List<ArticleDemande>> getArticles(int demandeId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/articles-demande/demande/$demandeId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les articles (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('La réponse doit être une liste JSON.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => ArticleDemande.fromJson(json))
        .toList();
  }
}

// Provider du repository des articles.
final articleDemandeRepositoryProvider =
Provider<ArticleDemandeRepository>((ref) {
  return ArticleDemandeRepository(ref.watch(httpClientProvider));
});

// Provider pour charger les articles d'une demande précise.
final articlesDemandeProvider =
FutureProvider.family<List<ArticleDemande>, int>((ref, demandeId) {
  return ref.watch(articleDemandeRepositoryProvider).getArticles(demandeId);
});