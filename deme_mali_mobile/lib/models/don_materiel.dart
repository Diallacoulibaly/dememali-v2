
class DonMateriel {
  final int id;
  final String designation;
  final int quantite;
  final String unite;
  final int quantiteRecue;
  final String statutReception;
  final int? demandeAideId;
  final int? organisationPartenaireId;

  const DonMateriel({
    required this.id,
    required this.designation,
    required this.quantite,
    required this.unite,
    required this.quantiteRecue,
    required this.statutReception,
    this.demandeAideId,
    this.organisationPartenaireId,
  });

  factory DonMateriel.fromJson(Map<String, dynamic> json) {
    return DonMateriel(
      id: (json['id'] as num).toInt(),
      designation: json['designation']?.toString() ?? '',
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
      unite: json['unite']?.toString() ?? '',
      quantiteRecue: (json['quantiteRecue'] as num?)?.toInt() ?? 0,
      statutReception:
      json['statutReception']?.toString() ?? 'EN_ATTENTE',
      demandeAideId: (json['demandeAideId'] as num?)?.toInt(),
      organisationPartenaireId:
      (json['organisationPartenaireId'] as num?)?.toInt(),
    );
  }
}
