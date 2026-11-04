import 'dart:convert';

import 'package:deme_mali_mobile/models/donnees_personnelles_particulier.dart';
import 'package:deme_mali_mobile/repositories/auth_repository.dart';
import 'package:deme_mali_mobile/repositories/particulier_repository.dart';
import 'package:deme_mali_mobile/repositories/structure_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('inscription particulier appelle le backend avec le formulaire', () async {
    final client = MockClient((requete) async {
      expect(requete.url.toString(),
          '${AuthRepository.apiUrl}/beneficiaires/particuliers');
      expect(requete.headers['Content-Type'], contains('application/json'));
      final donnees = jsonDecode(requete.body) as Map<String, dynamic>;
      expect(donnees['organisationPartenaireId'], 5);
      expect(donnees['situationMatrimonial'], 'MARIE');
      return http.Response('{}', 201);
    });
    addTearDown(client.close);

    await ParticulierRepository(client: client).inscrire(
      personnel: const DonneesPersonnellesParticulier(
        nom: 'Coulibaly',
        prenom: 'Assetou',
        adresse: 'Djicoroni',
        ville: 'Bamako',
        telephone: '60982323',
        motDePasse: 'mot-de-passe-test',
        genre: 'Femme',
      ),
      organisationPartenaireId: 5,
      situationMatrimonial: 'MARIE',
      nombreEnfants: 2,
      typeHandicap: 'Moteur',
      descriptionSituation: 'Besoins prioritaires',
      dateNaissance: '1990-01-03',
    );
  });

  test('inscription structure appelle le backend', () async {
    final client = MockClient((requete) async {
      expect(requete.url.toString(),
          '${AuthRepository.apiUrl}/beneficiaires/structures');
      expect(requete.headers['Content-Type'], contains('application/json'));
      final donnees = jsonDecode(requete.body) as Map<String, dynamic>;
      expect(donnees['organisationPartenaireId'], 5);
      expect(donnees['typeBeneficiaire'], 'STRUCTURE');
      return http.Response('{}', 201);
    });
    addTearDown(client.close);

    await StructureRepository(client: client).inscrire(
      nom: 'Coulibaly',
      prenom: 'Assetou',
      telephone: '60982323',
      motDePasse: 'mot-de-passe-test',
      ville: 'Bamako',
      adresse: 'Djicoroni',
      organisationPartenaireId: 5,
      nomStructure: 'Association test',
      nif: 'NIF123',
      email: 'test@example.com',
    );
  });
}
