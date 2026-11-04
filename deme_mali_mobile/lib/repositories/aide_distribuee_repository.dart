
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/aide_distribuee.dart';

class AideDistribueeRepository {
  final String baseUrl;
  final http.Client _client;

  AideDistribueeRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Récupérer les distributions d'une organisation.
  Future<List<AideDistribuee>> getByOrganisation(
      int organisationId,
      ) async {
    return _getList(
      '/api/aides-distribuees/organisation/$organisationId',
    );
  }

  // Récupérer les distributions liées à une demande précise.
  Future<List<AideDistribuee>> getByDemande(
      int demandeAideId,
      ) async {
    return _getList(
      '/api/aides-distribuees/demande/$demandeAideId',
    );
  }

  // Récupérer les distributions liées à un bénéficiaire.
  Future<List<AideDistribuee>> getByBeneficiaire(
      int beneficiaireId,
      ) async {
    return _getList(
      '/api/aides-distribuees/beneficiaire/$beneficiaireId',
    );
  }

  // NOUVEAU : récupérer uniquement les distributions terminées
  // d'une demande.
  Future<List<AideDistribuee>> getDistribueesByDemande(
      int demandeAideId,
      ) async {
    return _getList(
      '/api/aides-distribuees/demande/$demandeAideId/distribuees',
    );
  }

  // NOUVEAU : récupérer uniquement les distributions terminées
  // d'un bénéficiaire.
  Future<List<AideDistribuee>> getDistribueesByBeneficiaire(
      int beneficiaireId,
      ) async {
    return _getList(
      '/api/aides-distribuees/beneficiaire/$beneficiaireId/distribuees',
    );
  }

  // Récupérer une distribution par son identifiant.
  Future<AideDistribuee> getById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/aides-distribuees/$id'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger la distribution '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format incorrect pour une aide distribuée.',
      );
    }

    return AideDistribuee.fromJson(decoded);
  }

  // Méthode commune pour récupérer une liste de distributions.
  Future<List<AideDistribuee>> _getList(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les aides distribuées '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw const FormatException(
        'La réponse des aides distribuées doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une aide distribuée.',
        );
      }

      return AideDistribuee.fromJson(element);
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}
