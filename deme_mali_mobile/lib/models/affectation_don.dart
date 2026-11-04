
class AffectationDon {
  final int id;
  final double? montantAffecte;
  final String? dateAffectation;
  final int? donFinancierId;
  final int? demandeAideId;
  final int? aideDistribueeId;
  final int? beneficiaireId;
  final int? organisationPartenaireId;

  const AffectationDon({
    required this.id,
    this.montantAffecte,
    this.dateAffectation,
    this.donFinancierId,
    this.demandeAideId,
    this.aideDistribueeId,
    this.beneficiaireId,
    this.organisationPartenaireId,
  });

  factory AffectationDon.fromJson(Map<String, dynamic> json) {
    return AffectationDon(
      id: (json['id'] as num?)?.toInt() ?? 0,
      montantAffecte: (json['montantAffecte'] as num?)?.toDouble(),
      dateAffectation: json['dateAffectation']?.toString(),
      donFinancierId: (json['donFinancierId'] as num?)?.toInt(),
      demandeAideId: (json['demandeAideId'] as num?)?.toInt(),
      aideDistribueeId: (json['aideDistribueeId'] as num?)?.toInt(),
      beneficiaireId: (json['beneficiaireId'] as num?)?.toInt(),
      organisationPartenaireId:
      (json['organisationPartenaireId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'montantAffecte': montantAffecte,
    'dateAffectation': dateAffectation,
    'donFinancierId': donFinancierId,
    'demandeAideId': demandeAideId,
    'aideDistribueeId': aideDistribueeId,
    'beneficiaireId': beneficiaireId,
    'organisationPartenaireId': organisationPartenaireId,
  };
}
