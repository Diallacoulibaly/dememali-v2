
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/organisation_partenaire.dart';
import 'auth_repository.dart';
import 'http_client_provider.dart';

class OrganisationPartenaireRepository {
  final String baseUrl;
  final http.Client _client;

  OrganisationPartenaireRepository(this._client, {
    required this.baseUrl,
  });

  /// Liste des organisations validées avec leurs informations de likes.
  Future<List<OrganisationPartenaire>> getOrganisationsAvecLikes({
    required int donateurId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/organisations-partenaires/liste-avec-likes',
    ).replace(
      queryParameters: {
        'donateurId': donateurId.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les organisations '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

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

  /// Détails d'une organisation par son identifiant.
  Future<OrganisationPartenaire> getOrganisationById(
      int organisationId,
      ) async {
   final uri = Uri.parse(
  '$baseUrl/organisations-partenaires/$organisationId',
);

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger cette organisation '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Format incorrect pour les détails de l’organisation.',
      );
    }

    return OrganisationPartenaire.fromJson(decoded);
  }

}

/// Repository disponible dans Riverpod.
final organisationPartenaireRepositoryProvider =
Provider<OrganisationPartenaireRepository>((ref) {
  final baseUrl = '${AuthRepository.baseUrl}/api';

  return OrganisationPartenaireRepository(
    ref.watch(httpClientProvider),
    baseUrl: baseUrl,
  );
});

/// Chargement de la liste pour un donateur donné.
final organisationsAvecLikesProvider =
FutureProvider.family<List<OrganisationPartenaire>, int>(
      (ref, donateurId) {
    final repository = ref.watch(
      organisationPartenaireRepositoryProvider,
    );

    return repository.getOrganisationsAvecLikes(
      donateurId: donateurId,
    );
  },
);

/// Chargement des détails d'une organisation.
final organisationParIdProvider =
FutureProvider.family<OrganisationPartenaire, int>(
      (ref, organisationId) {
    final repository = ref.watch(
      organisationPartenaireRepositoryProvider,
    );

    return repository.getOrganisationById(organisationId);
  },
);
