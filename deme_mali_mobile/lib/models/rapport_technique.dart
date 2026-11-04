
import 'detail_rapport_technique.dart';

class RapportTechnique {
  final int id;
  final int? rapportBesoinId;
  final double montantFinal;
  final List<DetailRapportTechnique> details;

  const RapportTechnique({
    required this.id,
    this.rapportBesoinId,
    required this.montantFinal,
    required this.details,
  });

  factory RapportTechnique.fromJson(
      Map<String, dynamic> json,
      ) {
    double decimal(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int entier(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final detailsJson = json['details'];

    return RapportTechnique(
      id: entier(json['id']),
      rapportBesoinId: json['rapportBesoinId'] == null
          ? null
          : entier(json['rapportBesoinId']),
      montantFinal: decimal(json['montantFinal']),
      details: detailsJson is List
          ? detailsJson
          .whereType<Map<String, dynamic>>()
          .map(DetailRapportTechnique.fromJson)
          .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rapportBesoinId': rapportBesoinId,
      'montantFinal': montantFinal,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}
