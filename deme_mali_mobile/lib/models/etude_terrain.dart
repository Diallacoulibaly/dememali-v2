
class EtudeTerrain {
  final int id;
  final DateTime? dateRealisation;
  final DateTime? datePlanification;
  final String? lieu;
  final String? objectif;
  final String? observation;
  final String? resultat;
  final String? heure;
  final String? statut;

  const EtudeTerrain({
    required this.id,
    this.dateRealisation,
    this.datePlanification,
    this.lieu,
    this.objectif,
    this.observation,
    this.resultat,
    this.heure,
    this.statut,
  });

  factory EtudeTerrain.fromJson(Map<String, dynamic> json) {
    return EtudeTerrain(
      id: (json['id'] as num).toInt(),
      dateRealisation: _parseDate(json['dateRealisation']),
      datePlanification: _parseDate(json['datePlanification']),
      lieu: json['lieu'] as String?,
      objectif: json['objectif'] as String?,
      observation: json['observation'] as String?,
      resultat: json['resultat'] as String?,
      heure: json['heure']?.toString(),
      statut: (json['statut'] ?? json['status'])?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
