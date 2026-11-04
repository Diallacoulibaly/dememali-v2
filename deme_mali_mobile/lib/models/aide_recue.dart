import 'demande_aide.dart';

/// Représente une affectation financière liée à une distribution
class AffectationFinanciere {
  final int id;
  final int donFinancierId;
  final double montantAffecte;
  final String? dateAffectation;

  const AffectationFinanciere({
    required this.id,
    required this.donFinancierId,
    required this.montantAffecte,
    this.dateAffectation,
  });

  factory AffectationFinanciere.fromJson(Map<String, dynamic> json) {
    double decimal(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? 0.0));
    int integer(dynamic v) =>
        v == null ? 0 : (v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0));

    return AffectationFinanciere(
      id: integer(json['id']),
      donFinancierId: integer(json['donFinancierId']),
      montantAffecte: decimal(json['montantAffecte']),
      dateAffectation: json['dateAffectation']?.toString(),
    );
  }
}

/// Représente une affectation matérielle liée à une distribution
class AffectationMaterielle {
  final int id;
  final int? donMaterielId;
  final String designation;
  final int quantiteAffectee;
  final String unite;
  final double? valeurAffectee;
  final String? dateAffectation;

  const AffectationMaterielle({
    required this.id,
    this.donMaterielId,
    required this.designation,
    required this.quantiteAffectee,
    required this.unite,
    this.valeurAffectee,
    this.dateAffectation,
  });

  factory AffectationMaterielle.fromJson(Map<String, dynamic> json) {
    int integer(dynamic v) =>
        v == null ? 0 : (v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0));
    double? decimal(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

    return AffectationMaterielle(
      id: integer(json['id']),
      donMaterielId: json['donMaterielId'] != null ? integer(json['donMaterielId']) : null,
      designation: (json['designation'] ?? 'Article').toString(),
      quantiteAffectee: integer(json['quantiteAffectee']),
      unite: (json['unite'] ?? '').toString(),
      valeurAffectee: decimal(json['valeurAffectee']),
      dateAffectation: json['dateAffectation']?.toString(),
    );
  }
}

/// Modèle représentant une aide distribuée, correspondant à AideDistribueeResponseDTO en backend.
class AideRecue {
  final int id;
  final int? demandeAideId;
  final int? beneficiaireId;
  final String? dateDistribution;
  final String? lieuDistribution;
  final String statut;
  final List<AffectationFinanciere> affectationsFinancieres;
  final List<AffectationMaterielle> affectationsMaterielles;
  final DemandeAide? demandeAssociee;
  final int? nombreDonateurs;

  const AideRecue({
    required this.id,
    this.demandeAideId,
    this.beneficiaireId,
    this.dateDistribution,
    this.lieuDistribution,
    this.statut = 'DISTRIBUEE',
    this.affectationsFinancieres = const [],
    this.affectationsMaterielles = const [],
    this.demandeAssociee,
    this.nombreDonateurs,
  });

  String get reference => 'RÉF : AR-${id.toString().padLeft(4, '0')}';
  String get titre => titreAffiche;
  String get montant => valeurAffichee;
  String get dateReception => dateAffichee;

  /// Nombre de donateurs ayant contribué
  int get totalDonateurs =>
      nombreDonateurs ?? (affectationsFinancieres.isNotEmpty ? affectationsFinancieres.length : 0);

  /// Indique si cette aide distribuée provient d'une demande soumise par le bénéficiaire
  bool get estLieeADemande => demandeAideId != null;

  /// Calcul du montant total financier distribué
  double get totalFinancier => affectationsFinancieres.fold(
        0.0,
        (somme, aff) => somme + aff.montantAffecte,
      );

  /// Indique si l'aide comporte des dons financiers
  bool get aDonFinancier => affectationsFinancieres.isNotEmpty && totalFinancier > 0;

  /// Indique si l'aide comporte des dons matériels
  bool get aDonMateriel => affectationsMaterielles.isNotEmpty;

  /// Titre d'affichage dynamique sans le caractère '#'
  String get titreAffiche {
    if (estLieeADemande) {
      return 'Aide liée à la demande $demandeAideId';
    }
    if (aDonMateriel && !aDonFinancier) {
      return affectationsMaterielles.length == 1
          ? affectationsMaterielles.first.designation
          : 'Distribution de vivres et matériel';
    }
    return 'Distribution d\'aide directe';
  }

  /// Formatage lisible du montant ou du résumé des articles
  String get valeurAffichee {
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    if (aDonFinancier && !aDonMateriel) {
      final formate = totalFinancier.round().toString().replaceAllMapped(
            regex,
            (m) => '${m[1]} ',
          );
      return '$formate FCFA';
    } else if (aDonMateriel && !aDonFinancier) {
      return affectationsMaterielles
          .map((m) => '${m.quantiteAffectee} ${m.unite.isNotEmpty ? m.unite : 'unité(s)'} (${m.designation})')
          .join(', ');
    } else if (aDonFinancier && aDonMateriel) {
      final formate = totalFinancier.round().toString().replaceAllMapped(
            regex,
            (m) => '${m[1]} ',
          );
      return '$formate FCFA + ${affectationsMaterielles.length} article(s)';
    }
    return 'Aide distribuée';
  }

  /// Formatage de la date de réception
  String get dateAffichee {
    if (dateDistribution != null && dateDistribution!.isNotEmpty) {
      return 'Reçue le $dateDistribution';
    }
    return 'Aide distribuée';
  }

  AideRecue copyWith({
    int? id,
    int? demandeAideId,
    int? beneficiaireId,
    String? dateDistribution,
    String? lieuDistribution,
    String? statut,
    List<AffectationFinanciere>? affectationsFinancieres,
    List<AffectationMaterielle>? affectationsMaterielles,
    DemandeAide? demandeAssociee,
    int? nombreDonateurs,
  }) {
    return AideRecue(
      id: id ?? this.id,
      demandeAideId: demandeAideId ?? this.demandeAideId,
      beneficiaireId: beneficiaireId ?? this.beneficiaireId,
      dateDistribution: dateDistribution ?? this.dateDistribution,
      lieuDistribution: lieuDistribution ?? this.lieuDistribution,
      statut: statut ?? this.statut,
      affectationsFinancieres: affectationsFinancieres ?? this.affectationsFinancieres,
      affectationsMaterielles: affectationsMaterielles ?? this.affectationsMaterielles,
      demandeAssociee: demandeAssociee ?? this.demandeAssociee,
      nombreDonateurs: nombreDonateurs ?? this.nombreDonateurs,
    );
  }

  factory AideRecue.fromJson(Map<String, dynamic> json) {
    int integer(dynamic v) =>
        v == null ? 0 : (v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0));

    final affFinancieres = (json['affectationsFinancieres'] is List)
        ? (json['affectationsFinancieres'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AffectationFinanciere.fromJson)
            .toList()
        : <AffectationFinanciere>[];

    final affMaterielles = (json['affectationsMaterielles'] is List)
        ? (json['affectationsMaterielles'] as List)
            .whereType<Map<String, dynamic>>()
            .map(AffectationMaterielle.fromJson)
            .toList()
        : <AffectationMaterielle>[];

    return AideRecue(
      id: integer(json['id']),
      demandeAideId: json['demandeAideId'] != null ? integer(json['demandeAideId']) : null,
      beneficiaireId: json['beneficiaireId'] != null ? integer(json['beneficiaireId']) : null,
      dateDistribution: json['dateDistribution']?.toString(),
      lieuDistribution: json['lieuDistribution']?.toString(),
      statut: (json['statut'] ?? 'DISTRIBUEE').toString(),
      affectationsFinancieres: affFinancieres,
      affectationsMaterielles: affMaterielles,
      nombreDonateurs: json['nombreDonateurs'] != null ? integer(json['nombreDonateurs']) : null,
    );
  }
}
