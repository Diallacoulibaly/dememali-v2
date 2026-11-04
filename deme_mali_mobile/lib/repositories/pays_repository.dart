
import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_repository.dart';

class PaysRepository {
  static String get baseUrl => AuthRepository.baseUrl;
  static Map<String, int>? _cache;

  // Récupère les pays enregistrés dans le backend : nom (en minuscules) -> id.
  // Endpoint public : GET /api/pays
  Future<Map<String, int>> recupererIdsParNom({bool forcer = false}) async {
    if (!forcer && _cache != null && _cache!.isNotEmpty) {
      return _cache!;
    }

    try {
      final reponse = await http
          .get(
            Uri.parse('$baseUrl/api/pays'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Délai d’attente dépassé pour les pays.'),
          );

      if (reponse.statusCode == 200) {
        final dynamic liste = jsonDecode(utf8.decode(reponse.bodyBytes));
        if (liste is List) {
          final resultat = <String, int>{};
          for (final element in liste) {
            if (element is Map) {
              final nom = element['nom']?.toString().trim().toLowerCase() ?? '';
              final id = (element['id'] as num?)?.toInt();
              if (nom.isNotEmpty && id != null) {
                resultat[nom] = id;
                // Version sans accent pour sécurité
                final sansAccents = nom
                    .replaceAll('é', 'e')
                    .replaceAll('è', 'e')
                    .replaceAll('ê', 'e');
                resultat[sansAccents] = id;
              }
            }
          }
          if (resultat.isNotEmpty) {
            _cache = resultat;
            return resultat;
          }
        }
      }
    } catch (e) {
      debugPrint('ERREUR CHARGEMENT PAYS : $e');
    }

    // Si le serveur tarde ou en cas d'indisponibilité temporaire,
    // on assure que le Mali (id 1) est utilisable sans bloquer l'utilisateur
    _cache ??= {'mali': 1};
    return _cache!;
  }
}

