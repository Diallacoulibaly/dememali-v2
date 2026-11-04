import '../repositories/auth_repository.dart';

class ImageDemande {
  final int id;
  final String nomFichier;
  final String cheminFichier;

  const ImageDemande({
    required this.id,
    required this.nomFichier,
    required this.cheminFichier,
  });

  // URL publique de l'image
  String get urlImage {
    if (cheminFichier.isEmpty) return '';

    final nom = cheminFichier.replaceAll('\\', '/').split('/').last;
    if (nom.isEmpty) return '';

    return '${AuthRepository.baseUrl}/uploads/images-demandes/'
        '${Uri.encodeComponent(nom)}';
  }

  factory ImageDemande.fromJson(Map<String, dynamic> json) {
    return ImageDemande(
      id: json['id'],
      nomFichier: json['nomFichier'] ?? '',
      cheminFichier: json['cheminFichier'] ?? '',
    );
  }
}