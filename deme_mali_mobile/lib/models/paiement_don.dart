
class PaiementDon {
  final int id;
  final int? donFinancierId;
  final double montant;
  final String? referenceTransaction;
  final DateTime datePaiement;
  final DateTime? dateConfirmation;
  final String statut;

  PaiementDon({
    required this.id,
    this.donFinancierId,
    required this.montant,
    this.referenceTransaction,
    required this.datePaiement,
    this.dateConfirmation,
    required this.statut,
  });

  // Convertir la réponse du backend en objet Dart.
  factory PaiementDon.fromJson(Map<String, dynamic> json) {
    return PaiementDon(
      id: (json['id'] as num).toInt(),
      donFinancierId: (json['donFinancierId'] as num?)?.toInt(),
      montant: (json['montant'] as num).toDouble(),
      referenceTransaction: json['referenceTransaction'] as String?,
      datePaiement: DateTime.parse(json['datePaiement'] as String),
      dateConfirmation: json['dateConfirmation'] != null
          ? DateTime.parse(json['dateConfirmation'] as String)
          : null,
      statut: json['statut'] as String,
    );
  }

  // Convertir l'objet Dart en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donFinancierId': donFinancierId,
      'montant': montant,
      'referenceTransaction': referenceTransaction,
      'datePaiement': datePaiement.toIso8601String(),
      'dateConfirmation': dateConfirmation?.toIso8601String(),
      'statut': statut,
    };
  }

  bool get estConfirme => statut == 'CONFIRME';

  bool get estEchec => statut == 'ECHEC';
}
