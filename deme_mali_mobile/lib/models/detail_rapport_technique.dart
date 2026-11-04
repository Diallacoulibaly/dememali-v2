
class DetailRapportTechnique {
  final int? id;
  final String designation;
  final int quantite;
  final String unite;
  final double prixUnitaire;
  final double montant;
  final int? rapportTechniqueId;

  const DetailRapportTechnique({
    this.id,
    required this.designation,
    required this.quantite,
    required this.unite,
    required this.prixUnitaire,
    required this.montant,
    this.rapportTechniqueId,
  });

  factory DetailRapportTechnique.fromJson(
      Map<String, dynamic> json,
      ) {
    double decimal(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int entier(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return DetailRapportTechnique(
      id: json['id'] == null ? null : entier(json['id']),
      designation: json['designation']?.toString() ?? '',
      quantite: entier(json['quantite']),
      unite: json['unite']?.toString() ?? '',
      prixUnitaire: decimal(json['prixUnitaire']),
      montant: decimal(json['montant']),
      rapportTechniqueId: json['rapportTechniqueId'] == null
          ? null
          : entier(json['rapportTechniqueId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'designation': designation,
      'quantite': quantite,
      'unite': unite,
      'prixUnitaire': prixUnitaire,
      'montant': montant,
      'rapportTechniqueId': rapportTechniqueId,
    };
  }
}
