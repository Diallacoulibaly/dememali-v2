
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/donnees_personnelles_particulier.dart';
import 'auth_repository.dart';

class ParticulierRepository {
  static String get baseUrl => AuthRepository.apiUrl;
  final http.Client? client;

  ParticulierRepository({this.client});

  // Inscription d'un bénéficiaire particulier :
  // POST /api/beneficiaires/particuliers
  //
  // Valeurs d'enum vérifiées sur le backend :
  //  - typeBeneficiaireParticulier : PERSONNE | FAMILLE
  //  - situationMatrimonial : CELIBATAIRE | MARIE | DIVORCE | VEUVE
  //  - dateNaissance : AAAA-MM-JJ
  Future<void> inscrire({
    required DonneesPersonnellesParticulier personnel,
    required int organisationPartenaireId,
    required String situationMatrimonial,
    required int nombreEnfants,
    required String typeHandicap,
    required String descriptionSituation,
    required String dateNaissance,
  }) async {
    final payload = <String, dynamic>{
      'nom': personnel.nom.trim(),
      'prenom': personnel.prenom.trim(),
      'telephone': personnel.telephone,
      'motDePasse': personnel.motDePasse,
      'adresse': personnel.adresse.trim(),
      'ville': personnel.ville.trim(),
      'typeBeneficiaire': 'PARTICULIER',
      'situationMatrimonial': situationMatrimonial,
      'nombreEnfants': nombreEnfants,
      'typeHandicap': typeHandicap,
      'descriptionSituation': descriptionSituation.trim(),
      'dateNaissance': dateNaissance,
      'organisationPartenaireId': organisationPartenaireId,
      'sexe': (personnel.genre.toUpperCase() == 'FEMME' ||
              personnel.genre.toUpperCase() == 'FEMININ')
          ? 'FEMININ'
          : 'MASCULIN',
    };

    final payloadStr = jsonEncode(payload);
    final url = Uri.parse('$baseUrl/beneficiaires/particuliers');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final reponse = await (client?.post(url, headers: headers, body: payloadStr) ??
        http.post(url, headers: headers, body: payloadStr));

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
