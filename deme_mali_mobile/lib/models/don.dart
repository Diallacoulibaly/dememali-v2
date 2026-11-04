
class Don {
  final int id;
  final DateTime? dateDon;
  final String? typeDon;
  final bool anonyme;

  final int? donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;

  const Don({
    required this.id,
    this.dateDon,
    this.typeDon,
    this.anonyme = false,

    this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId,
  });

  factory Don.fromJson(Map<String, dynamic> json) {
    int? integer(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    DateTime? date(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    bool boolean(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return Don(
      id: integer(json['id']) ?? 0,
      dateDon: date(json['dateDon']),
      typeDon: json['typeDon']?.toString(),
      anonyme: boolean(json['anonyme']),

      donateurId: integer(json['donateurId']),
      demandeAideId: integer(json['demandeAideId']),
      organisationPartenaireId:
      integer(json['organisationPartenaireId']),
    );
  }
}
