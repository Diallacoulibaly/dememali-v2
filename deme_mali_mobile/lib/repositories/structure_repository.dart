import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_repository.dart';

class StructureRepository {
  static String get baseUrl => AuthRepository.apiUrl;
  final http.Client? client;

  StructureRepository({this.client});

  // Inscription d'un bénéficiaire structure :
  // POST /api/beneficiaires/structures
  //
  // Corps attendu (BeneficiaireStructureRequestDTO) :
  // nom, prenom, telephone, motDePasse, ville, adresse,
  // organisationPartenaireId, typeBeneficiaire (STRUCTURE),
  // nina, nif, email, nomStructure, documentJustificatif.
  Future<void> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String ville,
    required String adresse,
    required int organisationPartenaireId,
    required String nomStructure,
    required String nif,
    required String email,
    String? documentJustificatif,
  }) async {
    final corpsEnvoi = jsonEncode({
      'nom': nom.trim(),
      'prenom': prenom.trim(),
      'telephone': telephone,
      'motDePasse': motDePasse,
      'ville': ville.trim(),
      'adresse': adresse.trim(),
      'organisationPartenaireId': organisationPartenaireId,
      'typeBeneficiaire': 'STRUCTURE',
      'nomStructure': nomStructure.trim(),
      'nif': nif.trim(),
      'nina': nif.trim(), // nina alimenté avec le nif si non spécifié
      'email': email.trim(),
      'documentJustificatif': documentJustificatif ?? '',
    });

    final url = Uri.parse('$baseUrl/beneficiaires/structures');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final reponse = await (client?.post(url, headers: headers, body: corpsEnvoi) ??
            http.post(url, headers: headers, body: corpsEnvoi))
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw Exception('Délai d’attente dépassé avec le serveur.'),
        );

    if (reponse.statusCode == 201 || reponse.statusCode == 200) {
      return;
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
}
