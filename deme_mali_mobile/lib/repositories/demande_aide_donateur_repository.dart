import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/demande_aide.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

class DemandeAideRepository {
  static String get baseUrl => '${AuthRepository.baseUrl}/api';

  final http.Client client;

  DemandeAideRepository({required this.client});

  // Récupérer les demandes disponibles pour les dons.
  // Conditions : demande validée et collecte non terminée.
  Future<List<DemandeAide>> getDemandesDisponibles() async {
    final response = await client.get(
      Uri.parse('$baseUrl/demandes-aide/disponibles-pour-don'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les demandes (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException(
        'La réponse doit être une liste JSON.',
      );
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((json) => DemandeAide.fromJson(json))
        .where(
          (demande) =>
      demande.statut == 'VALIDEE' &&
          demande.statutCollecte != 'TERMINEE',
    )
        .toList();
  }

  // Récupérer une demande par son identifiant.
  Future<DemandeAide> getDemandeById(int id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/demandes-aide/$id'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer la demande (${response.statusCode}).',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'La réponse doit être un objet JSON.',
      );
    }

    return DemandeAide.fromJson(decoded);
  }
}

// Provider du repository des demandes.
final demandeAideRepositoryProvider =
Provider<DemandeAideRepository>((ref) {
  return DemandeAideRepository(
    client: ref.watch(httpClientProvider),
  );
});

// Provider pour charger les demandes disponibles.
final demandesDisponiblesProvider =
FutureProvider<List<DemandeAide>>((ref) {
  return ref
      .watch(demandeAideRepositoryProvider)
      .getDemandesDisponibles();
});

// Provider pour charger une demande par son identifiant.
final demandeAideDetailProvider =
FutureProvider.family<DemandeAide, int>((ref, id) {
  return ref
      .watch(demandeAideRepositoryProvider)
      .getDemandeById(id);
});
