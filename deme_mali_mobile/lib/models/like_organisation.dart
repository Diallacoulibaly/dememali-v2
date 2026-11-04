
class LikeOrganisation {
  final int donateurId;
  final int organisationId;

  const LikeOrganisation({
    required this.donateurId,
    required this.organisationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'donateurId': donateurId,
      'organisationId': organisationId,
    };
  }

  factory LikeOrganisation.fromJson(Map<String, dynamic> json) {
    return LikeOrganisation(
      donateurId: (json['donateurId'] as num).toInt(),
      organisationId: (json['organisationId'] as num).toInt(),
    );
  }
}
