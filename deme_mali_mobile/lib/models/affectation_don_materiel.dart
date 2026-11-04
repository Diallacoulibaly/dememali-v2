
class AffectationDonMateriel {
  final int id;
  final int? donMaterielId;
  final String? designation;
  final int? quantiteAffectee;
  final String? unite;
  final String? dateAffectation;
  final int? demandeAideId;
  final int? beneficiaireId;
  final int? organisationPartenaireId;

  const AffectationDonMateriel({
    required this.id,
    this.donMaterielId,
    this.designation,
    this.quantiteAffectee,
    this.unite,
    this.dateAffectation,
    this.demandeAideId,
    this.beneficiaireId,
    this.organisationPartenaireId,
  });

  factory AffectationDonMateriel.fromJson(Map<String, dynamic> json) {
    return AffectationDonMateriel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      donMaterielId: (json['donMaterielId'] as num?)?.toInt(),
      designation: json['designation']?.toString(),
      quantiteAffectee: (json['quantiteAffectee'] as num?)?.toInt(),
      unite: json['unite']?.toString(),
      dateAffectation: json['dateAffectation']?.toString(),
      demandeAideId: (json['demandeAideId'] as num?)?.toInt(),
      beneficiaireId: (json['beneficiaireId'] as num?)?.toInt(),
      organisationPartenaireId:
      (json['organisationPartenaireId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'donMaterielId': donMaterielId,
    'designation': designation,
    'quantiteAffectee': quantiteAffectee,
    'unite': unite,
    'dateAffectation': dateAffectation,
    'demandeAideId': demandeAideId,
    'beneficiaireId': beneficiaireId,
    'organisationPartenaireId': organisationPartenaireId,
  };
}
