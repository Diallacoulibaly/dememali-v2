
class Pays {
  final String code;
  final String nom;
  final String indicatif;
  final List<String> villes;

  const Pays({
    required this.code,
    required this.nom,
    required this.indicatif,
    required this.villes,
  });

  // Pays proposés lors de l'inscription
  static const List<Pays> liste = [
    Pays(
      code: 'ML',
      nom: 'Mali',
      indicatif: '+223',
      villes: [
        'Bamako',
        'Kayes',
        'Koulikoro',
        'Sikasso',
        'Ségou',
        'Mopti',
        'Tombouctou',
        'Gao',
        'Kidal',
      ],
    ),
    Pays(
      code: 'SN',
      nom: 'Sénégal',
      indicatif: '+221',
      villes: ['Dakar', 'Thiès', 'Saint-Louis', 'Kaolack', 'Ziguinchor'],
    ),
    Pays(
      code: 'CI',
      nom: "Côte d'Ivoire",
      indicatif: '+225',
      villes: ['Abidjan', 'Yamoussoukro', 'Bouaké', 'San-Pédro', 'Korhogo'],
    ),
    Pays(
      code: 'GN',
      nom: 'Guinée',
      indicatif: '+224',
      villes: ['Conakry', 'Kankan', 'Labé', 'Nzérékoré', 'Kindia'],
    ),
    Pays(
      code: 'BF',
      nom: 'Burkina Faso',
      indicatif: '+226',
      villes: ['Ouagadougou', 'Bobo-Dioulasso', 'Koudougou', 'Banfora'],
    ),
    Pays(
      code: 'NE',
      nom: 'Niger',
      indicatif: '+227',
      villes: ['Niamey', 'Zinder', 'Maradi', 'Agadez', 'Tahoua'],
    ),
  ];
}
