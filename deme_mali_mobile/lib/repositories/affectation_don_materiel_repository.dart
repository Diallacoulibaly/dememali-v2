
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/affectation_don_materiel.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

class AffectationDonMaterielRepository {
  final String baseUrl;
  final http.Client _client;

  AffectationDonMaterielRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Récupère les affectations matérielles d'un don.
  Future<List<AffectationDonMateriel>> getByDonMateriel(
      int donMaterielId,
      ) async {
    return _getList(
      '/api/affectations-dons-materiels/don/$donMaterielId',
    );
  }

  /// Récupère les affectations matérielles directes d'un bénéficiaire.
  Future<List<AffectationDonMateriel>> getByBeneficiaire(
      int beneficiaireId,
      ) async {
    return _getList(
      '/api/affectations-dons-materiels/beneficiaire/$beneficiaireId',
    );
  }

  /// Récupère toutes les affectations matérielles.
  Future<List<AffectationDonMateriel>> getAll() async {
    return _getList('/api/affectations-dons-materiels');
  }

  Future<List<AffectationDonMateriel>> _getList(
      String path,
      ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les affectations matérielles '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw const FormatException(
        'La réponse des affectations matérielles doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une affectation matérielle.',
        );
      }

      return AffectationDonMateriel.fromJson(element);
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}

/// Provider Riverpod du repository.
final affectationDonMaterielRepositoryProvider =
Provider<AffectationDonMaterielRepository>((ref) {
  final baseUrl = AuthRepository.baseUrl;

  final repository = AffectationDonMaterielRepository(
    baseUrl: baseUrl,
    client: ref.watch(httpClientProvider),
  );

  return repository;
});
