class Beneficiaire {
  final int id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? email;
  final String? typeBeneficiaire;
  final String? ville;
  final String? adresse;
  final String? statut;
  final int? organisationPartenaireId;

  // Détails de l'organisation partenaire associée
  final String? nomOrganisation;
  final String? nomStructure;
  final String? typeOrganisation;
  final String? telephoneOrganisation;
  final String? emailOrganisation;
  final String? villeOrganisation;
  final String? adresseOrganisation;
  // Photo de profil (chemin local ou URL distante)
  final String? photoUrl;

  const Beneficiaire({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.email,
    this.typeBeneficiaire,
    this.ville,
    this.adresse,
    this.statut,
    this.organisationPartenaireId,
    this.nomOrganisation,
    this.nomStructure,
    this.typeOrganisation,
    this.telephoneOrganisation,
    this.emailOrganisation,
    this.villeOrganisation,
    this.adresseOrganisation,
    this.photoUrl,
  });

  String get nomComplet {
    if (typeBeneficiaire?.toUpperCase() == 'STRUCTURE' &&
        nomStructure != null &&
        nomStructure!.trim().isNotEmpty) {
      return nomStructure!.trim();
    }
    final complet = '$prenom $nom'.trim();
    return complet.isNotEmpty ? complet : 'Bénéficiaire';
  }

  String get typeBeneficiaireAffiche {
    if (typeBeneficiaire == null || typeBeneficiaire!.isEmpty) return 'Particulier';
    switch (typeBeneficiaire!.toUpperCase()) {
      case 'PARTICULIER':
        return 'Particulier';
      case 'STRUCTURE':
        return 'Particulier';
      case 'FAMILLE':
        return 'Famille';
      case 'GROUPE':
      case 'COMMUNAUTE':
        return 'Communauté';
      default:
        return typeBeneficiaire!;
    }
  }

  String get nomOrganisationAffiche {
    if (nomOrganisation != null && nomOrganisation!.trim().isNotEmpty) {
      return nomOrganisation!.trim();
    }
    return 'Organisation partenaire';
  }

  Beneficiaire copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? typeBeneficiaire,
    String? ville,
    String? adresse,
    String? statut,
    int? organisationPartenaireId,
    String? nomOrganisation,
    String? nomStructure,
    String? typeOrganisation,
    String? telephoneOrganisation,
    String? emailOrganisation,
    String? villeOrganisation,
    String? adresseOrganisation,
    String? photoUrl,
  }) {
    return Beneficiaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      typeBeneficiaire: typeBeneficiaire ?? this.typeBeneficiaire,
      ville: ville ?? this.ville,
      adresse: adresse ?? this.adresse,
      statut: statut ?? this.statut,
      organisationPartenaireId: organisationPartenaireId ?? this.organisationPartenaireId,
      nomOrganisation: nomOrganisation ?? this.nomOrganisation,
      nomStructure: nomStructure ?? this.nomStructure,
      typeOrganisation: typeOrganisation ?? this.typeOrganisation,
      telephoneOrganisation: telephoneOrganisation ?? this.telephoneOrganisation,
      emailOrganisation: emailOrganisation ?? this.emailOrganisation,
      villeOrganisation: villeOrganisation ?? this.villeOrganisation,
      adresseOrganisation: adresseOrganisation ?? this.adresseOrganisation,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory Beneficiaire.fromJson(Map<String, dynamic> json) => Beneficiaire(
        id: (json['id'] as num?)?.toInt() ?? 0,
        nom: (json['nom'] ?? '').toString(),
        prenom: (json['prenom'] ?? '').toString(),
        telephone: json['telephone']?.toString(),
        email: json['email']?.toString(),
        typeBeneficiaire: json['typeBeneficiaire']?.toString(),
        ville: json['ville']?.toString(),
        adresse: json['adresse']?.toString(),
        statut: json['statut']?.toString(),
        organisationPartenaireId: (json['organisationPartenaireId'] as num?)?.toInt(),
        nomStructure: json['nomStructure']?.toString(),
        photoUrl: json['photoUrl']?.toString() ?? json['photo']?.toString(),
      );

  factory Beneficiaire.fromApi({
    required Map<String, dynamic> beneficiaireJson,
    Map<String, dynamic>? organisationJson,
    String? telephoneFallback,
    String? nomFallback,
    String? prenomFallback,
    String? photoFallback,
  }) {
    final id = (beneficiaireJson['id'] as num?)?.toInt() ?? 0;
    var nom = (beneficiaireJson['nom'] ?? '').toString().trim();
    var prenom = (beneficiaireJson['prenom'] ?? '').toString().trim();
    if (nom.isEmpty && nomFallback != null) nom = nomFallback;
    if (prenom.isEmpty && prenomFallback != null) prenom = prenomFallback;

    final telephone = beneficiaireJson['telephone']?.toString() ?? telephoneFallback;
    final email = beneficiaireJson['email']?.toString() ?? organisationJson?['email']?.toString();
    final typeBeneficiaire = beneficiaireJson['typeBeneficiaire']?.toString();
    final nomStructure = beneficiaireJson['nomStructure']?.toString();
    final ville = beneficiaireJson['ville']?.toString() ?? organisationJson?['ville']?.toString();
    final adresse = beneficiaireJson['adresse']?.toString() ?? organisationJson?['adresse']?.toString();
    final statut = beneficiaireJson['statut']?.toString();
    final orgId = (beneficiaireJson['organisationPartenaireId'] as num?)?.toInt() ??
        (organisationJson?['id'] as num?)?.toInt();

    final nomOrg = organisationJson?['nomOrganisation']?.toString();
    final typeOrg = organisationJson?['typeOrganisation']?.toString();
    final telOrg = organisationJson?['telephoneOrganisation']?.toString() ??
        organisationJson?['telephone']?.toString();
    final emailOrg = organisationJson?['email']?.toString();
    final villeOrg = organisationJson?['ville']?.toString();
    final adresseOrg = organisationJson?['adresse']?.toString();
    final photo = beneficiaireJson['photoUrl']?.toString() ??
        beneficiaireJson['photo']?.toString() ??
        photoFallback;

    return Beneficiaire(
      id: id,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      email: email,
      typeBeneficiaire: typeBeneficiaire,
      ville: ville,
      adresse: adresse,
      statut: statut,
      organisationPartenaireId: orgId,
      nomOrganisation: nomOrg,
      nomStructure: nomStructure,
      typeOrganisation: typeOrg,
      telephoneOrganisation: telOrg,
      emailOrganisation: emailOrg,
      villeOrganisation: villeOrg,
      adresseOrganisation: adresseOrg,
      photoUrl: photo,
    );
  }
}

