
class DonFinancier {
  final int id;
  final String modePaiement;
  final double montant;
  final DateTime? dateDon;
  final bool anonyme;
  final String typeDon;
  final int? donateurId;
  final int? demandeAideId;
  final String? titreDemandeAide;
  final int? organisationPartenaireId;

  DonFinancier({
    required this.id,
    required this.modePaiement,
    required this.montant,
    this.dateDon,
    required this.anonyme,
    required this.typeDon,
    this.donateurId,
    this.demandeAideId,
    this.titreDemandeAide,
    this.organisationPartenaireId,
  });

  factory DonFinancier.fromJson(Map<String, dynamic> json) {
    return DonFinancier(
      id: (json['id'] as num).toInt(),
      modePaiement: json['modePaiement'] as String,
      montant: (json['montant'] as num).toDouble(),
      dateDon: json['dateDon'] != null
          ? DateTime.parse(json['dateDon'] as String)
          : null,
      anonyme: json['anonyme'] as bool? ?? false,
      typeDon: json['typeDon'] as String,
      donateurId: (json['donateurId'] as num?)?.toInt(),
      demandeAideId: (json['demandeAideId'] as num?)?.toInt(),
      titreDemandeAide: json['titreDemandeAide'] as String?,
      organisationPartenaireId:
      (json['organisationPartenaireId'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modePaiement': modePaiement,
      'montant': montant,
      'dateDon': dateDon?.toIso8601String().split('T').first,
      'anonyme': anonyme,
      'typeDon': typeDon,
      'donateurId': donateurId,
      'demandeAideId': demandeAideId,
      'titreDemandeAide': titreDemandeAide,
      'organisationPartenaireId': organisationPartenaireId,
    };
  }
}
