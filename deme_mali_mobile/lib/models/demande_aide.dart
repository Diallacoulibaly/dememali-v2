import 'article_demande.dart';

class DemandeAide {
  final int id;
  final int nombreDonateurs;
  final String titre;
  final String descriptionSituation;
  final String niveauUrgence;
  final String statut;
  final DateTime? dateCreation;
  final String? motif;
  final int? nombrePersonne;
  final double? montantNecessaire;
  final double? montantCollecte;
  final String? statutCollecte;
  final int? beneficiaireId;
  final String? beneficiaireNom;
  final String? beneficiairePrenom;
  final int? organisationPartenaireId;
  final int? categorieDemandeId;
  final String? categorieDemandeNom;
  final String? typeDemande;
  final String? typeDemandeAide;
  final List<ArticleDemande> articles;
  // Montant validé par l'équipe technique après étude de terrain
  final double? montantFinal;
  final String? descriptionTechnique;

  const DemandeAide({
    required this.id,
    this.nombreDonateurs = 0,
    required this.titre,
    required this.descriptionSituation,
    required this.niveauUrgence,
    required this.statut,
    this.dateCreation,
    this.motif,
    this.nombrePersonne,
    this.montantNecessaire,
    this.montantCollecte,
    this.statutCollecte,
    this.beneficiaireId,
    this.beneficiaireNom,
    this.beneficiairePrenom,
    this.organisationPartenaireId,
    this.categorieDemandeId,
    this.categorieDemandeNom,
    this.typeDemande,
    this.typeDemandeAide,
    this.articles = const [],
    this.montantFinal,
    this.descriptionTechnique,
  });

  factory DemandeAide.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) {
      return value == null ? null : DateTime.tryParse(value.toString());
    }

    int? integer(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? decimal(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    dynamic rawArticles = json['articles'] ?? json['articlesDemandes'] ?? json['articlesDemande'];
    List<ArticleDemande> articlesList = const [];
    if (rawArticles is List) {
      articlesList = rawArticles
          .whereType<Map<String, dynamic>>()
          .map(ArticleDemande.fromJson)
          .toList();
    }

    return DemandeAide(
      id: integer(json['id']) ?? 0,
      nombreDonateurs: integer(json['nombreDonateurs'] ?? json['nombreDonateur'] ?? json['donateursCount']) ?? 0,
      titre: (json['titre'] ?? '').toString(),
      descriptionSituation: (json['descriptionSituation'] ?? json['description'] ?? '').toString(),
      niveauUrgence: (json['niveauUrgence'] ?? json['urgence'] ?? 'Urgente').toString(),
      statut: (json['statut'] ?? '').toString(),
      dateCreation: date(json['dateCreation'] ?? json['dateDemande'] ?? json['createdAt']),
      motif: json['motif']?.toString() ?? json['motifRejet']?.toString(),
      nombrePersonne: integer(json['nombrePersonne'] ?? json['nombrePersonnes'] ?? json['nbPersonnes']),
      montantNecessaire: decimal(json['montantNecessaire']) ?? decimal(json['montant']) ?? decimal(json['montantTotal']),
      montantCollecte: decimal(json['montantCollecte']) ?? decimal(json['montantRecu']) ?? 0.0,
      statutCollecte: json['statutCollecte']?.toString(),
      beneficiaireId: integer(json['beneficiaireId'] ?? (json['beneficiaire'] is Map ? json['beneficiaire']['id'] : null)),
      beneficiaireNom: json['beneficiaireNom']?.toString() ?? (json['beneficiaire'] is Map ? json['beneficiaire']['nom']?.toString() : null),
      beneficiairePrenom: json['beneficiairePrenom']?.toString() ?? (json['beneficiaire'] is Map ? json['beneficiaire']['prenom']?.toString() : null),
      organisationPartenaireId: integer(json['organisationPartenaireId'] ??
          (json['organisationPartenaire'] is Map ? json['organisationPartenaire']['id'] : null) ??
          (json['organisation'] is Map ? json['organisation']['id'] : null)),
      categorieDemandeId: integer(json['categorieDemandeId'] ?? (json['categorie'] is Map ? json['categorie']['id'] : null) ?? (json['categorieDemande'] is Map ? json['categorieDemande']['id'] : null)),
      categorieDemandeNom: json['categorieDemandeNom']?.toString() ??
          (json['categorie'] is Map ? json['categorie']['nom']?.toString() : null) ??
          (json['categorieDemande'] is Map ? json['categorieDemande']['nom']?.toString() : null) ??
          json['categorieNom']?.toString(),
      typeDemande: json['typeDemande']?.toString() ?? json['type']?.toString(),
      typeDemandeAide: json['typeDemandeAide']?.toString() ?? json['natureAide']?.toString(),
      articles: articlesList,
      montantFinal: decimal(json['montantFinal'] ?? json['montantApresEtude'] ?? json['montantTechnique']),
      descriptionTechnique: json['descriptionTechnique']?.toString(),
    );
  }

  DemandeAide copyWith({
    int? id,
    String? titre,
    String? descriptionSituation,
    String? niveauUrgence,
    String? statut,
    DateTime? dateCreation,
    String? motif,
    int? nombrePersonne,
    double? montantNecessaire,
    double? montantCollecte,
    String? statutCollecte,
    int? beneficiaireId,
    String? beneficiaireNom,
    String? beneficiairePrenom,
    int? organisationPartenaireId,
    int? categorieDemandeId,
    String? categorieDemandeNom,
    String? typeDemande,
    String? typeDemandeAide,
    List<ArticleDemande>? articles,
    double? montantFinal,
    String? descriptionTechnique,
    int? nombreDonateurs,
  }) {
    return DemandeAide(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      descriptionSituation: descriptionSituation ?? this.descriptionSituation,
      niveauUrgence: niveauUrgence ?? this.niveauUrgence,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      motif: motif ?? this.motif,
      nombrePersonne: nombrePersonne ?? this.nombrePersonne,
      montantNecessaire: montantNecessaire ?? this.montantNecessaire,
      montantCollecte: montantCollecte ?? this.montantCollecte,
      statutCollecte: statutCollecte ?? this.statutCollecte,
      beneficiaireId: beneficiaireId ?? this.beneficiaireId,
      beneficiaireNom: beneficiaireNom ?? this.beneficiaireNom,
      beneficiairePrenom: beneficiairePrenom ?? this.beneficiairePrenom,
      organisationPartenaireId: organisationPartenaireId ?? this.organisationPartenaireId,
      categorieDemandeId: categorieDemandeId ?? this.categorieDemandeId,
      categorieDemandeNom: categorieDemandeNom ?? this.categorieDemandeNom,
      typeDemande: typeDemande ?? this.typeDemande,
      typeDemandeAide: typeDemandeAide ?? this.typeDemandeAide,
      articles: articles ?? this.articles,
      montantFinal: montantFinal ?? this.montantFinal,
      descriptionTechnique: descriptionTechnique ?? this.descriptionTechnique,
      nombreDonateurs: nombreDonateurs ?? this.nombreDonateurs,
    );
  }

  /// Total estimé des articles
  double get totalArticles =>
      articles.fold(0.0, (somme, a) => somme + a.sousTotal);

  /// Montant effectif requis pour la collecte :
  /// 1. Priorité absolue : Montant final validé après étude de terrain (Rapport Technique)
  /// 2. Si non encore évalué : Montant nécessaire initial ou estimation des articles
  double get montantTotalRequis {
    if (montantFinal != null && montantFinal! > 0) {
      return montantFinal!;
    }
    if (montantNecessaire != null && montantNecessaire! > 0) {
      return montantNecessaire!;
    }
    if (totalArticles > 0) {
      return totalArticles;
    }
    return 0.0;
  }

  /// Indique si la demande dispose déjà d'un montant certifié après étude de terrain
  bool get aMontantFinalCertifie => montantFinal != null && montantFinal! > 0;

  /// Ratio de collecte entre 0.0 et 1.0
  double get ratioCollecte {
    final total = montantTotalRequis;
    if (total <= 0) return 0.0;
    return ((montantCollecte ?? 0.0) / total).clamp(0.0, 1.0);
  }

  /// Pourcentage entier de collecte
  int get pourcentageCollecte => (ratioCollecte * 100).toInt();

  bool get estFinanciere {
    final type = (typeDemandeAide ?? typeDemande ?? '').toUpperCase();
    return type == 'FINANCIERE';
  }

  bool get estMaterielle {
    final type = (typeDemandeAide ?? typeDemande ?? '').toUpperCase();
    return type == 'MATERIELLE';
  }

  /// Comparateur pour trier du plus récent au plus ancien (décroissant)
  static int comparerPlusRecentDAbord(DemandeAide a, DemandeAide b) {
    if (a.dateCreation != null && b.dateCreation != null) {
      final comp = b.dateCreation!.compareTo(a.dateCreation!);
      if (comp != 0) return comp;
    } else if (a.dateCreation != null) {
      return -1; // 'a' possède une date récente, passe avant 'b'
    } else if (b.dateCreation != null) {
      return 1;  // 'b' possède une date, passe avant 'a'
    }
    // Si dates identiques ou nulles, tri par ID décroissant
    return b.id.compareTo(a.id);
  }
}
