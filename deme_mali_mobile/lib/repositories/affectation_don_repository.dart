
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/affectation_don.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

class AffectationDonRepository {
  final String baseUrl;
  final http.Client _client;

  AffectationDonRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Récupérer les affectations d'un don financier.
  Future<List<AffectationDon>> getByDon(
      int donFinancierId,
      ) async {
    return _getList(
      '/api/affectations-dons/don/$donFinancierId',
    );
  }

  /// Récupérer les affectations d'une demande d'aide.
  Future<List<AffectationDon>> getByDemande(
      int demandeAideId,
      ) async {
    return _getList(
      '/api/affectations-dons/demande/$demandeAideId',
    );
  }

  /// Récupérer toutes les affectations financières.
  Future<List<AffectationDon>> getAll() async {
    return _getList('/api/affectations-dons');
  }

  /// Récupérer une affectation par son identifiant.
  Future<AffectationDon> getById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/affectations-dons/$id'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger l’affectation '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format incorrect pour une affectation financière.',
      );
    }

    return AffectationDon.fromJson(decoded);
  }

  Future<List<AffectationDon>> _getList(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les affectations financières '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw const FormatException(
        'La réponse des affectations doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une affectation financière.',
        );
      }

      return AffectationDon.fromJson(element);
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}

/// Provider Riverpod du repository.
final affectationDonRepositoryProvider =
Provider<AffectationDonRepository>((ref) {
  final baseUrl = AuthRepository.baseUrl;

  final repository = AffectationDonRepository(
    baseUrl: baseUrl,
    client: ref.watch(httpClientProvider),
  );

  return repository;
});
