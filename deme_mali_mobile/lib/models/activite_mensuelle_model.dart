class ActiviteMensuelleModel {
  final String mois;
  final int annee;
  final double montantFinancier;
  final double montantMateriel;
  const ActiviteMensuelleModel({required this.mois, required this.annee,
    required this.montantFinancier, required this.montantMateriel});
  double get montantTotal => montantFinancier + montantMateriel;
}
