class Donateur {
  final int id;
  final String nom;
  final String prenom;
  final String telephone;
  final String? sexe;
  final int? paysId;
  final String? paysNom;
  final String? photo;

  const Donateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    this.sexe,
    this.paysId,
    this.paysNom,
    this.photo,
  });

  factory Donateur.fromJson(Map<String, dynamic> json) {
    return Donateur(
      id: (json['id'] as num).toInt(),
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      sexe: json['sexe']?.toString(),
      paysId: json['paysId'] == null
          ? null
          : (json['paysId'] as num).toInt(),
      paysNom: json['paysNom']?.toString(),
      photo: json['photo']?.toString() ?? json['photoUrl']?.toString(),
    );
  }

  String get nomComplet => '$prenom $nom'.trim();

  Donateur copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? telephone,
    String? sexe,
    int? paysId,
    String? paysNom,
    String? photo,
  }) {
    return Donateur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      sexe: sexe ?? this.sexe,
      paysId: paysId ?? this.paysId,
      paysNom: paysNom ?? this.paysNom,
      photo: photo ?? this.photo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'sexe': sexe,
      'paysId': paysId,
      'paysNom': paysNom,
      'photo': photo,
    };
  }
}
