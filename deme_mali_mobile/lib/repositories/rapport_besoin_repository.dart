import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/rapport_besoin.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart'; // adapte au nom réel de ton fichier

class RapportBesoinRepository {
  static String get baseUrl => AuthRepository.baseUrl;

  final http.Client _client;

  RapportBesoinRepository(this._client);

  /// Récupérer le rapport de besoin associé à une étude de terrain.
  Future<RapportBesoin?> getRapportBesoinPourEtude(
      int etudeTerrainId,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/rapports-besoin/etude-terrain/$etudeTerrainId',
    );

    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    // Aucun rapport de besoin n'est encore disponible.
    if (response.statusCode == 404) {
      return null;
    }

    // Une autre erreur est survenue.
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement du rapport de besoin '
            '(${response.statusCode}) : ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return RapportBesoin.fromJson(json);
  }
}

/// Provider du repository.
final rapportBesoinRepositoryProvider =
Provider<RapportBesoinRepository>((ref) {
  return RapportBesoinRepository(ref.watch(httpClientProvider));
});