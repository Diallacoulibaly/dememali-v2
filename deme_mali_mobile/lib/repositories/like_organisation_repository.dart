
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/like_organisation.dart';
import '../models/organisation_partenaire.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

class LikeOrganisationRepository {
  final String baseUrl;
  final http.Client _client;

  LikeOrganisationRepository(this._client, {
    required this.baseUrl,
  });

  /// Ajouter un like.
  Future<void> aimerOrganisation(LikeOrganisation like) async {
    final uri = Uri.parse(
      '$baseUrl/api/likes-organisations/${like.organisationId}',
    ).replace(
      queryParameters: {
        'donateurId': like.donateurId.toString(),
      },
    );

    final response = await _client.post(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur lors de l’ajout du like : HTTP ${response.statusCode}',
      );
    }
  }

  /// Retirer un like.
  Future<void> retirerLike(LikeOrganisation like) async {
    final uri = Uri.parse(
      '$baseUrl/api/likes-organisations/${like.organisationId}',
    ).replace(
      queryParameters: {
        'donateurId': like.donateurId.toString(),
      },
    );

    final response = await _client.delete(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Erreur lors du retrait du like : HTTP ${response.statusCode}',
      );
    }
  }

  /// Récupérer les organisations aimées par un donateur.
  Future<List<OrganisationPartenaire>> getOrganisationsAimees(
      int donateurId,
      ) async {
    final uri = Uri.parse(
      '$baseUrl/api/likes-organisations/donateur/$donateurId',
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les organisations aimées : '
            'HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! List) {
      throw const FormatException(
        'La réponse du serveur doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une organisation.',
        );
      }

      return OrganisationPartenaire.fromJson(element);
    }).toList();
  }

}

/// Provider du repository.
final likeOrganisationRepositoryProvider =
Provider<LikeOrganisationRepository>((ref) {
  final baseUrl = AuthRepository.baseUrl;

  return LikeOrganisationRepository(
    ref.watch(httpClientProvider),
    baseUrl: baseUrl,
  );
});

/// Provider de la liste des organisations aimées.
final organisationsAimeesProvider =
FutureProvider.family<List<OrganisationPartenaire>, int>(
      (ref, donateurId) {
    final repository = ref.watch(
      likeOrganisationRepositoryProvider,
    );

    return repository.getOrganisationsAimees(donateurId);
  },
);
