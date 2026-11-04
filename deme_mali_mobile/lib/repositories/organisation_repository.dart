
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/organisation_partenaire.dart';
import 'auth_repository.dart';

class OrganisationRepository {
  static String get baseUrl => '${AuthRepository.baseUrl}/api';
  static List<OrganisationPartenaire>? _cache;

  // Endpoint public : GET /api/organisations-partenaires
  // Met en cache la liste pour un affichage instantané lors des navigations
  Future<List<OrganisationPartenaire>> recupererValidees({bool forcer = false}) async {
    if (!forcer && _cache != null && _cache!.isNotEmpty) {
      debugPrint('>>> ORGANISATIONS (DEPUIS CACHE) : ${_cache!.length} trouvées');
      return _cache!;
    }

    debugPrint('>>> CHARGEMENT ORGANISATIONS DEPUIS $baseUrl/organisations-partenaires');

    final reponse = await http
        .get(
Uri.parse('$baseUrl/organisations-partenaires'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw TimeoutException('Délai d’attente dépassé pour les organisations.'),
        );

    debugPrint('<<< REPONSE ORGANISATIONS [${reponse.statusCode}]');

    if (reponse.statusCode != 200) {
      throw Exception(
        'Impossible de charger les organisations (${reponse.statusCode}).',
      );
    }

    final dynamic corps = jsonDecode(utf8.decode(reponse.bodyBytes));
    if (corps is! List) {
      return _cache ?? [];
    }

    final resultat = <OrganisationPartenaire>[];
    for (final element in corps) {
      if (element is Map) {
        final map = Map<String, dynamic>.from(element);
        final statut = map['statutValidation']?.toString().toUpperCase();
        if (statut == 'VALIDEE') {
          final org = OrganisationPartenaire.fromJson(map);
          if (org.nomOrganisation.isNotEmpty) {
            resultat.add(org);
          }
        }
      }
    }

    _cache = resultat;
    debugPrint('<<< ORGANISATIONS VALIDEES : ${resultat.length}');
    return resultat;
  }
}

