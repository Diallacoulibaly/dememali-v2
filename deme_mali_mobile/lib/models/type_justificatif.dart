class TypeJustificatif {
  final int id;
  final String nom;

  const TypeJustificatif({
    required this.id,
    required this.nom,
  });

  factory TypeJustificatif.fromJson(Map<String, dynamic> json) {
    return TypeJustificatif(
      id: (json['id'] is num
              ? (json['id'] as num).toInt()
              : int.tryParse(json['id']?.toString() ?? '0')) ??
          0,
      nom: (json['nom'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}
