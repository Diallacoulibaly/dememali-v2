
class DonneesPersonnellesParticulier {
  final String nom;
  final String prenom;
  final String adresse;
  final String ville;
  final String telephone;
  final String motDePasse;
  final String genre;

  const DonneesPersonnellesParticulier({
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.ville,
    required this.telephone,
    required this.motDePasse,
    this.genre = 'Homme',
  });
}

