import 'dart:typed_data';

class DonneesStructureEtape1 {
  final String nomStructure;
  final String typeStructure;
  final String nif;
  final String ville;
  final String adresse;

  const DonneesStructureEtape1({
    required this.nomStructure,
    required this.typeStructure,
    required this.nif,
    required this.ville,
    required this.adresse,
  });
}

class DonneesStructureEtape2 {
  final DonneesStructureEtape1 etape1;
  final String? nomDocument;
  final Uint8List? octetsDocument;
  final String email;

  const DonneesStructureEtape2({
    required this.etape1,
    this.nomDocument,
    this.octetsDocument,
    required this.email,
  });
}
