
class CategorieDemande {
  final int id;
  final String nom;

  const CategorieDemande({
    required this.id,
    required this.nom,
  });

  factory CategorieDemande.fromJson(Map<String, dynamic> json) {
    return CategorieDemande(
      id: (json['id'] as num).toInt(),
      nom: (json['nom'] ?? '').toString(),
    );
  }

  factory CategorieDemande.fromDemande({
    required int id,
    required String nom,
  }) {
    return CategorieDemande(id: id, nom: nom);
  }
}
