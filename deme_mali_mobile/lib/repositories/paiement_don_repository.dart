
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/paiement_don.dart';
import 'don_financier_repository.dart';
import 'package:flutter/foundation.dart';
import 'http_client_provider.dart';
// Fournisseur du dépôt des paiements.
final paiementDonRepositoryProvider =
Provider<PaiementDonRepository>((ref) {
  return PaiementDonRepository(
    baseUrl: apiBaseUrl,
    client: ref.watch(httpClientProvider),
  );
});

class PaiementDonRepository {
  final String baseUrl;
  final http.Client client;

  PaiementDonRepository({
    required this.baseUrl,
    required this.client,
  });

  // Effectuer un paiement via le backend.
  Future<PaiementDon> effectuerPaiement({
    required double montant,
    required String numeroTelephone,
    required String codeSecret,
    required int donateurId,
    required String modePaiement,
    required bool anonyme,
    int? demandeAideId,
    int? organisationPartenaireId,
  }) async {
    // Préparer les données attendues par le DTO Java.
    final Map<String, dynamic> donnees = {
      'montant': montant,
      'numeroTelephone': numeroTelephone,
      'codeSecret': codeSecret,
      'donateurId': donateurId,
      'modePaiement': modePaiement,
      'anonyme': anonyme,

    };

    // Ajouter l'identifiant uniquement pour un don affecté.
    if (demandeAideId != null) {
      donnees['demandeAideId'] = demandeAideId;
    }
    // Ajouter l'identifiant de l'organisation si le don lui est destiné.
    if (organisationPartenaireId != null) {
      donnees['organisationPartenaireId'] = organisationPartenaireId;
    }
    debugPrint('Données envoyées au paiement : ${jsonEncode(donnees)}');
    final response = await client.post(
      Uri.parse(
        '$baseUrl/api/paiements-dons/simuler',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(donnees),
    );

    // AJOUTE CES 3 LIGNES ICI
    debugPrint('URL paiement : $baseUrl/api/paiements-dons/simuler');
    debugPrint('Statut HTTP : ${response.statusCode}');
    debugPrint('Réponse backend : ${response.body}');

    // Une erreur HTTP doit être remontée à l'interface.
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message =
          'Une erreur est survenue lors du paiement.';

      try {
        final resultat = jsonDecode(response.body);

        if (resultat is Map<String, dynamic>) {
          message = resultat['message']?.toString() ??
              resultat['error']?.toString() ??
              message;
        } else if (response.body.isNotEmpty) {
          message = response.body;
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }

      throw Exception(message);
    }

    // La réponse est le PaiementDonResponseDTO.
    final resultat =
    jsonDecode(response.body) as Map<String, dynamic>;

    return PaiementDon.fromJson(resultat);
  }
}
