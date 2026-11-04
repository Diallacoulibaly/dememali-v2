
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/don.dart';

class DonRepository {
  final String baseUrl;
  final http.Client client;

  DonRepository({
    required this.baseUrl,
    required this.client,
  });

  /// Récupérer tous les dons
  Future<List<Don>> getAll() async {
    final uri = Uri.parse('$baseUrl/api/dons');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Don.fromJson(
        json as Map<String, dynamic>,
      ))
          .toList();
    }

    throw Exception(
      'Erreur lors du chargement des dons : ${response.statusCode}',
    );
  }

  /// Récupérer un don par son identifiant
  Future<Don> getById(int id) async {
    final uri = Uri.parse('$baseUrl/api/dons/$id');

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return Don.fromJson(data);
    }

    throw Exception(
      'Erreur lors du chargement du don $id : ${response.statusCode}',
    );
  }

  /// Récupérer les dons d'un donateur
  Future<List<Don>> getByDonateur(int donateurId) async {
    final uri = Uri.parse(
      '$baseUrl/api/dons/donateur/$donateurId',
    );

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Don.fromJson(
        json as Map<String, dynamic>,
      ))
          .toList();
    }

    throw Exception(
      'Erreur lors du chargement des dons du donateur '
          '$donateurId : ${response.statusCode}',
    );
  }

  /// Récupérer les dons associés à une demande d'aide
  Future<List<Don>> getByDemande(int demandeAideId) async {
    final uri = Uri.parse(
      '$baseUrl/api/dons/demande/$demandeAideId',
    );

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => Don.fromJson(
        json as Map<String, dynamic>,
      ))
          .toList();
    }

    throw Exception(
      'Erreur lors du chargement des dons de la demande '
          '$demandeAideId : ${response.statusCode}',
    );
  }

  /// Compter les donateurs distincts d'une demande
  Future<int> compterDonateurs(int demandeAideId) async {
    final dons = await getByDemande(demandeAideId);

    final Set<int> donateurs = dons
        .map((don) => don.donateurId)
        .whereType<int>()
        .toSet();

    return donateurs.length;
  }
}
