
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'http_client_provider.dart';
import '../models/don_materiel.dart';
import 'auth_repository.dart';

// Client HTTP

// Repository
class DonMaterielRepository {
  final http.Client client;
  final String baseUrl;

  final FlutterSecureStorage stockage;

  DonMaterielRepository({
    required this.client,
    required this.baseUrl,
    this.stockage = const FlutterSecureStorage(),
  });

  Future<Map<String, String>> _headers() async {
    final token = await stockage.read(key: 'accessToken');
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer ' + token,
    };
  }

  // Valeur du matériel réellement reçu par un donateur
  // pendant une période.
  Future<double> getValeurMaterielleRecue({
    required int donateurId,
    required DateTime debut,
    required DateTime fin,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/dons-materiels/donateur/'
          '$donateurId/statistiques/valeur',
    ).replace(
      queryParameters: {
        'debut': _formaterDate(debut),
        'fin': _formaterDate(fin),
      },
    );

    final response = await client
        .get(
      uri,
      headers: await _headers(),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de récupérer la valeur du matériel reçu. '
            'Code HTTP : ${response.statusCode}.',
      );
    }

    final dynamic resultat = jsonDecode(response.body);

    if (resultat is num) {
      return resultat.toDouble();
    }

    throw const FormatException(
      'La valeur du matériel reçue par le serveur est invalide.',
    );
  }

  // Format attendu par Spring Boot : yyyy-MM-dd
  String _formaterDate(DateTime date) {
    final annee = date.year.toString().padLeft(4, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final jour = date.day.toString().padLeft(2, '0');

    return '$annee-$mois-$jour';
  }

  // Consulter les dons matériels liés à une demande
  Future<List<DonMateriel>> getDonsParDemande(
      int demandeAideId,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/dons-materiels/demande/$demandeAideId',
    );

    try {
      final response = await client
          .get(
        url,
        headers: await _headers(),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Chargement des dons matériels impossible. '
              'Code HTTP : ${response.statusCode}. '
              'Réponse : ${response.body}',
        );
      }

      final dynamic donnees = jsonDecode(response.body);

      if (donnees is! List) {
        throw const FormatException(
          'La réponse de l’API doit être une liste JSON.',
        );
      }

      return donnees.map<DonMateriel>((element) {
        if (element is! Map) {
          throw const FormatException(
            'Un élément de la réponse JSON est invalide.',
          );
        }

        return DonMateriel.fromJson(
          Map<String, dynamic>.from(element),
        );
      }).toList();
    } on TimeoutException {
      throw Exception(
        'Délai dépassé. Vérifie que le serveur est démarré '
            'et que baseUrl correspond à ton environnement.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Impossible de joindre le serveur : ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Réponse JSON invalide : ${e.message}',
      );
    }
  }

  // Consulter les dons matériels par donateur
  Future<List<DonMateriel>> getByDonateur(
      int donateurId,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/dons-materiels/donateur/$donateurId',
    );

    try {
      final response = await client
          .get(
        url,
        headers: await _headers(),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Chargement des dons matériels du donateur impossible. '
              'Code HTTP : ${response.statusCode}. '
              'Réponse : ${response.body}',
        );
      }

      final dynamic donnees = jsonDecode(response.body);

      if (donnees is! List) {
        throw const FormatException(
          'La réponse de l’API doit être une liste JSON.',
        );
      }

      return donnees.map<DonMateriel>((element) {
        if (element is! Map) {
          throw const FormatException(
            'Un élément de la réponse JSON est invalide.',
          );
        }

        return DonMateriel.fromJson(
          Map<String, dynamic>.from(element),
        );
      }).toList();
    } on TimeoutException {
      throw Exception(
        'Délai dépassé lors du chargement des dons matériels.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Impossible de joindre le serveur : ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Réponse JSON invalide : ${e.message}',
      );
    }
  }

  // Créer un don matériel général
  Future<DonMateriel> creerDonMateriel({
    required String designation,
    required int quantite,
    required String unite,
    required String etatMateriel,
    required bool anonyme,
    required int donateurId,
    required String adresseLivraison,
    int? demandeAideId,
    int? organisationPartenaireId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/dons-materiels',
    );

    final donnees = <String, dynamic>{
      'designation': designation,
      'quantite': quantite,
      'unite': unite,
      'etatMateriel': etatMateriel,
      'anonyme': anonyme,
      'donateurId': donateurId,
      'demandeAideId': demandeAideId,
      'adresseLivraison': adresseLivraison,
      'organisationPartenaireId': organisationPartenaireId,
    };

    try {
      final response = await client
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(donnees),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          'Création du don impossible. '
              'Code HTTP : ${response.statusCode}. '
              'Réponse : ${response.body}',
        );
      }

      final dynamic resultat = jsonDecode(response.body);

      if (resultat is! Map) {
        throw const FormatException(
          'La réponse de création du don est invalide.',
        );
      }

      return DonMateriel.fromJson(
        Map<String, dynamic>.from(resultat),
      );
    } on TimeoutException {
      throw Exception(
        'Délai dépassé lors de la création du don.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Impossible de joindre le serveur : ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Réponse JSON invalide : ${e.message}',
      );
    }
  }
}

// Provider du repository
final donMaterielRepositoryProvider =
Provider<DonMaterielRepository>((ref) {
  final client = ref.watch(httpClientProvider);

  return DonMaterielRepository(
    client: client,
    baseUrl: AuthRepository.baseUrl,
  );
});

// Provider des dons matériels par demande
final donMaterielProvider =
FutureProvider.family<List<DonMateriel>, int>(
      (ref, demandeAideId) {
    final repository = ref.watch(
      donMaterielRepositoryProvider,
    );

    return repository.getDonsParDemande(demandeAideId);
  },
);

// Période de calcul de la valeur du matériel reçu
class PeriodeDonMateriel {
  final int donateurId;
  final DateTime debut;
  final DateTime fin;

  const PeriodeDonMateriel({
    required this.donateurId,
    required this.debut,
    required this.fin,
  });
}

// Provider de la valeur du matériel réellement reçu
final valeurMaterielleRecueProvider =
FutureProvider.family<double, PeriodeDonMateriel>(
      (ref, periode) {
    final repository = ref.watch(
      donMaterielRepositoryProvider,
    );

    return repository.getValeurMaterielleRecue(
      donateurId: periode.donateurId,
      debut: periode.debut,
      fin: periode.fin,
    );
  },
);
