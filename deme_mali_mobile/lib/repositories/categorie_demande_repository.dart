
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/categorie_demande.dart';

class CategorieDemandeRepository {
  final String baseUrl;
  final http.Client client;

  CategorieDemandeRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<CategorieDemande>> obtenirCategories() async {
    final uri = Uri.parse('$baseUrl/api/categories-demande');

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> donnees = jsonDecode(response.body);

      return donnees
          .map(
            (json) => CategorieDemande.fromJson(
          json as Map<String, dynamic>,
        ),
      )
          .toList();
    }

    throw Exception(
      'Impossible de charger les catégories '
          '(HTTP ${response.statusCode}).',
    );
  }
}
