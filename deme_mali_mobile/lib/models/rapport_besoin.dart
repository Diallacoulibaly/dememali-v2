
class RapportBesoin {
  final int id;
  final String? titre;
  final String? besoinIdentifie;
  final String? descriptionSituation;
  final String? solutionProposee;
  final double? montantEstime;
  final DateTime? dateCreation;
  final int? etudeTerrainId;
  final int? rapportTechniqueId;
  final String? statutDemande;

  const RapportBesoin({
    required this.id,
    this.titre,
    this.besoinIdentifie,
    this.descriptionSituation,
    this.solutionProposee,
    this.montantEstime,
    this.dateCreation,
    this.etudeTerrainId,
    this.rapportTechniqueId,
    this.statutDemande,
  });

  factory RapportBesoin.fromJson(Map<String, dynamic> json) {
    return RapportBesoin(
      id: (json['id'] as num).toInt(),
      titre: json['titre'] as String?,
      besoinIdentifie: json['besoinIdentifie'] as String?,
      descriptionSituation: json['descriptionSituation'] as String?,
      solutionProposee: json['solutionProposee'] as String?,
      montantEstime: json['montantEstime'] == null
          ? null
          : (json['montantEstime'] as num).toDouble(),
      dateCreation: json['dateCreation'] == null
          ? null
          : DateTime.tryParse(
        json['dateCreation'].toString(),
      ),
      etudeTerrainId: json['etudeTerrainId'] == null
          ? null
          : (json['etudeTerrainId'] as num).toInt(),
      rapportTechniqueId: json['rapportTechniqueId'] == null
          ? null
          : (json['rapportTechniqueId'] as num).toInt(),
      statutDemande: json['statutDemande']?.toString(),
    );
  }
}
