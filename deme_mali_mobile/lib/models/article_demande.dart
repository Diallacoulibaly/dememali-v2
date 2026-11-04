/// Article demandé dans le cadre d'une demande d'aide matérielle.
/// Correspond à ArticleDemandeRequestDTO / ArticleDemandeResponseDTO du backend.
class ArticleDemande {
  final int? id;
  final String designation;
  final int quantiteDemandee;
  final String unite;
  final double? prixUnitaireEstime;

  const ArticleDemande({
    this.id,
    required this.designation,
    required this.quantiteDemandee,
    required this.unite,
    this.prixUnitaireEstime,
  });

  /// Sous-total estimé pour cet article (quantité * prix unitaire)
  double get sousTotal => (prixUnitaireEstime ?? 0.0) * quantiteDemandee;

  ArticleDemande copyWith({
    int? id,
    String? designation,
    int? quantiteDemandee,
    String? unite,
    double? prixUnitaireEstime,
  }) {
    return ArticleDemande(
      id: id ?? this.id,
      designation: designation ?? this.designation,
      quantiteDemandee: quantiteDemandee ?? this.quantiteDemandee,
      unite: unite ?? this.unite,
      prixUnitaireEstime: prixUnitaireEstime ?? this.prixUnitaireEstime,
    );
  }

  factory ArticleDemande.fromJson(Map<String, dynamic> json) {
    int? integer(dynamic v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
    double? decimal(dynamic v) => v == null
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    return ArticleDemande(
      id: integer(json['id']),
      designation: (json['designation'] ?? '').toString(),
      quantiteDemandee: integer(json['quantiteDemandee']) ?? 0,
      unite: (json['unite'] ?? '').toString(),
      prixUnitaireEstime: decimal(json['prixUnitaireEstime']),
    );
  }

  /// Corps JSON envoyé au backend (sans `id`, généré côté serveur).
  Map<String, dynamic> toJson() => {
        'designation': designation.trim(),
        'quantiteDemandee': quantiteDemandee,
        'unite': unite.trim(),
        'prixUnitaireEstime': prixUnitaireEstime ?? 0,
      };
}
