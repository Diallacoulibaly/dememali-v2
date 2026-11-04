
import 'preuve_distribution.dart';

class AideDistribuee {
  final int id;
  final int? demandeAideId;
  final int? beneficiaireId;
  final String? dateDistribution;
  final String? lieuDistribution;
  final String? statut;

  final List<PreuveDistribution> preuves;

  // Conservés pour exploiter les détails des dons affectés
  // lorsque nous construirons la page.
  final List<Map<String, dynamic>> affectationsFinancieres;
  final List<Map<String, dynamic>> affectationsMaterielles;

  const AideDistribuee({
    required this.id,
    this.demandeAideId,
    this.beneficiaireId,
    this.dateDistribution,
    this.lieuDistribution,
    this.statut,
    this.preuves = const [],
    this.affectationsFinancieres = const [],
    this.affectationsMaterielles = const [],
  });

  factory AideDistribuee.fromJson(
      Map<String, dynamic> json,
      ) {
    final preuvesJson = json['preuves'];
    final financieresJson = json['affectationsFinancieres'];
    final materiellesJson = json['affectationsMaterielles'];

    return AideDistribuee(
      id: (json['id'] as num?)?.toInt() ?? 0,
      demandeAideId:
      (json['demandeAideId'] as num?)?.toInt(),
      beneficiaireId:
      (json['beneficiaireId'] as num?)?.toInt(),
      dateDistribution:
      json['dateDistribution']?.toString(),
      lieuDistribution:
      json['lieuDistribution']?.toString(),
      statut: json['statut']?.toString(),

      preuves: preuvesJson is List
          ? preuvesJson
          .whereType<Map<String, dynamic>>()
          .map(PreuveDistribution.fromJson)
          .toList()
          : const [],

      affectationsFinancieres: financieresJson is List
          ? financieresJson
          .whereType<Map<String, dynamic>>()
          .toList()
          : const [],

      affectationsMaterielles: materiellesJson is List
          ? materiellesJson
          .whereType<Map<String, dynamic>>()
          .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'demandeAideId': demandeAideId,
      'beneficiaireId': beneficiaireId,
      'dateDistribution': dateDistribution,
      'lieuDistribution': lieuDistribution,
      'statut': statut,
      'preuves': preuves.map((p) => p.toJson()).toList(),
      'affectationsFinancieres': affectationsFinancieres,
      'affectationsMaterielles': affectationsMaterielles,
    };
  }
}
