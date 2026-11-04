
class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String role;
  final String? typeOrganisation;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    this.typeOrganisation,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      role: json['role'] as String,
      typeOrganisation: json['typeOrganisation'] as String?,
    );
  }
}
