import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/etude_terrain.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart'; // adapte au nom réel de ton fichier

class EtudeTerrainRepository {
  static String get baseUrl => AuthRepository.baseUrl;

  final http.Client _client;

  EtudeTerrainRepository(this._client);

  Future<EtudeTerrain?> getEtudePourDemande(int demandeId) async {
    final url = Uri.parse(
      '$baseUrl/api/etudes-terrain/demande/$demandeId',
    );

    final response = await _client.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors du chargement de l’étude de terrain '
            '(${response.statusCode}) : ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return EtudeTerrain.fromJson(json);
  }
}

// Provider Riverpod du repository.
final etudeTerrainRepositoryProvider = Provider<EtudeTerrainRepository>((ref) {
  return EtudeTerrainRepository(ref.watch(httpClientProvider));
});