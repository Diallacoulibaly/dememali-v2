class BadgeDonateurModel {
  final int id;
  final String code;
  final String nom;
  final String? imageUrl;
  final double montantMinimum;
  final bool obtenu;
  final String? semestre;
  final int? annee;

  const BadgeDonateurModel({
    required this.id,
    required this.code,
    required this.nom,
    this.imageUrl,
    required this.montantMinimum,
    required this.obtenu,
    this.semestre,
    this.annee,
  });

  factory BadgeDonateurModel.fromJson(Map<String, dynamic> json) => BadgeDonateurModel(
    id: _int(json['id']),
    code: '${json['code'] ?? ''}',
    nom: '${json['nom'] ?? 'Badge'}',
    imageUrl: (json['imageUrl'] ??
            json['image_url'] ??
            json['urlImage'] ??
            json['image'] ??
            json['cheminFichier'] ??
            json['chemin'] ??
            json['photo'] ??
            json['nomFichier'] ??
            json['icone'] ??
            json['icon'] ??
            json['badgeUrl'])
        ?.toString(),
    montantMinimum: _double(
      json['montantMinimum'] ??
          json['montant_minimum'] ??
          json['montantMin'] ??
          json['seuil'],
    ),
    obtenu: _parseObtenu(
      json['obtenu'] ??
          json['estObtenu'] ??
          json['isObtenu'] ??
          json['attribue'] ??
          json['estAttribue'] ??
          json['debloque'] ??
          json['statut'] ??
          json['status'],
    ),
    semestre: (json['semestre'] ?? json['semestreActuel'])?.toString(),
    annee: json['annee'] == null ? null : _int(json['annee']),
  );

  static bool _parseObtenu(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v > 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' ||
        s == '1' ||
        s == 'obtenu' ||
        s == 'attribue' ||
        s == 'debloque' ||
        s == 'valide' ||
        s == 'confirme';
  }

  /// Libellé clair du semestre pour l'affichage (ex: "Semestre 1 (Jan - Juin) 2026")
  String get libelleSemestre {
    if (semestre == null || semestre!.isEmpty) return '';
    final s = semestre!.toUpperCase();
    final nomSem = s == 'S1'
        ? 'Semestre 1 (Jan - Juin)'
        : (s == 'S2' ? 'Semestre 2 (Juil - Déc)' : s);
    return annee != null ? '$nomSem $annee' : nomSem;
  }

  /// Code court du semestre (ex: "S1 2026")
  String get semestreCourt {
    if (semestre == null || semestre!.isEmpty) return '';
    final s = semestre!.toUpperCase();
    return annee != null ? '$s $annee' : s;
  }

  /// Construit l'URL complète et absolue vers l'image du badge dans /uploads/badges/.
  String? urlComplete(String baseUrl) {
    String? raw = imageUrl;
    if (raw == null || raw.trim().isEmpty) {
      if (code.trim().isNotEmpty) {
        return '$baseUrl/uploads/badges/${code.trim().toLowerCase()}.png';
      }
      return null;
    }

    raw = raw.trim();

    // Remplacer localhost ou 127.0.0.1 par l'adresse IP du serveur
    if (raw.startsWith('http://localhost:8080') || raw.startsWith('http://127.0.0.1:8080')) {
      final indexPort = raw.indexOf(':8080');
      final chemin = raw.substring(indexPort + 5);
      return '$baseUrl$chemin';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // Normalisation des chemins relatifs vers /uploads/badges/
    if (raw.startsWith('/uploads/badges/') || raw.startsWith('/uploads/')) {
      return '$baseUrl$raw';
    }
    if (raw.startsWith('uploads/badges/') || raw.startsWith('uploads/')) {
      return '$baseUrl/$raw';
    }
    if (raw.startsWith('/badges/')) {
      return '$baseUrl/uploads$raw';
    }
    if (raw.startsWith('badges/')) {
      return '$baseUrl/uploads/$raw';
    }

    // Nom de fichier direct (ex: "bronze.png" ou "/bronze.png")
    final nomFichier = raw.startsWith('/') ? raw.substring(1) : raw;
    return '$baseUrl/uploads/badges/$nomFichier';
  }

  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _double(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;}