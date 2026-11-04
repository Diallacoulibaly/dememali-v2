/// Modèle représentant un document justificatif synchronisé avec le backend Spring Boot.
class Justificatif {
  final int? id;
  final String nom; // Correspond à "nomFichier" dans Spring Boot
  final String? chemin; // Correspond à "cheminFichier" dans Spring Boot
  final DateTime? dateAjout; // Correspond à "dateAjout" (LocalDate)
  final int? typeJustificatifId; // Correspond à typeJustificatif.id
  final int? demandeAideId; // Correspond à demandeAide.id

  // Attributs pour l'affichage mobile et l'upload
  final String taille;
  final String extension;
  final List<int>? octets;

  const Justificatif({
    this.id,
    required this.nom,
    this.taille = '',
    this.extension = 'pdf',
    this.chemin,
    this.dateAjout,
    this.typeJustificatifId,
    this.demandeAideId,
    this.octets,
  });

  /// Création d'une instance depuis le JSON renvoyé par Spring Boot
  factory Justificatif.fromJson(Map<String, dynamic> json) {
    int? integer(dynamic v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));
    DateTime? date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    final nomFichier = (json['nomFichier'] ?? json['nom'] ?? '').toString();

    // Déduire l'extension à partir du nom si non fournie
    String ext = (json['extension'] ?? '').toString();
    if (ext.isEmpty && nomFichier.contains('.')) {
      ext = nomFichier.split('.').last.toLowerCase();
    }
    if (ext.isEmpty) ext = 'pdf';

    // Récupération de l'id typeJustificatif (objet imbriqué ou id plat)
    int? typeId;
    if (json['typeJustificatif'] is Map) {
      typeId = integer(json['typeJustificatif']['id']);
    } else {
      typeId = integer(json['typeJustificatifId']);
    }

    // Récupération de l'id demandeAide (objet imbriqué ou id plat)
    int? demandeId;
    if (json['demandeAide'] is Map) {
      demandeId = integer(json['demandeAide']['id']);
    } else {
      demandeId = integer(json['demandeAideId']);
    }

    return Justificatif(
      id: integer(json['id']),
      nom: nomFichier,
      chemin: (json['cheminFichier'] ?? json['chemin'] ?? '').toString(),
      dateAjout: date(json['dateAjout']),
      typeJustificatifId: typeId,
      demandeAideId: demandeId,
      taille: (json['taille'] ?? '').toString(),
      extension: ext,
    );
  }

  /// Conversion de l'objet pour l'envoi en JSON à Spring Boot
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomFichier': nom,
      if (chemin != null) 'cheminFichier': chemin,
      if (dateAjout != null)
        'dateAjout':
            '${dateAjout!.year.toString().padLeft(4, '0')}-${dateAjout!.month.toString().padLeft(2, '0')}-${dateAjout!.day.toString().padLeft(2, '0')}',
      if (typeJustificatifId != null)
        'typeJustificatif': {'id': typeJustificatifId},
      if (demandeAideId != null)
        'demandeAide': {'id': demandeAideId},
    };
  }
}
