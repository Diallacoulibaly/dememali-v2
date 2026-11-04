
import 'utilisateur.dart';

class ReponseConnexion {
  final String accessToken;
  final Utilisateur utilisateur;

  ReponseConnexion({
    required this.accessToken,
    required this.utilisateur,
  });

  factory ReponseConnexion.fromJson(
      Map<String, dynamic> json,
      ) {
    return ReponseConnexion(
      accessToken: json['accessToken'] as String,
      utilisateur: Utilisateur.fromJson(
        (json['user'] ?? json['utilisateur']) as Map<String, dynamic>,
      ),
    );
  }
}
