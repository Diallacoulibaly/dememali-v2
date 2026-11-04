
class PreuveDistribution {
  final int id;
  final String? nomFichier;
  final String? urlFichier;
  final String? typeMedia;

  const PreuveDistribution({
    required this.id,
    this.nomFichier,
    this.urlFichier,
    this.typeMedia,
  });

  factory PreuveDistribution.fromJson(
      Map<String, dynamic> json,
      ) {
    return PreuveDistribution(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nomFichier: json['nomFichier']?.toString(),
      urlFichier: json['urlFichier']?.toString(),
      typeMedia: json['typeMedia']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomFichier': nomFichier,
      'urlFichier': urlFichier,
      'typeMedia': typeMedia,
    };
  }
}
