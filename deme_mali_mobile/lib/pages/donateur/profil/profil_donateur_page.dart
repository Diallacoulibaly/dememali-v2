import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:deme_mali_mobile/models/don_financier.dart';
import 'package:deme_mali_mobile/models/badge_donateur_model.dart';
import 'package:deme_mali_mobile/models/donateur.dart';
import 'package:deme_mali_mobile/controllers/badge_controller.dart';
import 'package:deme_mali_mobile/controllers/don_financier_controller.dart';
import 'package:deme_mali_mobile/repositories/donateur_repository.dart';
import 'package:deme_mali_mobile/repositories/auth_repository.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';
import '../../authentification/connexion.dart';

class ProfilDonateurPage extends ConsumerStatefulWidget {
  final int donateurId;
  final String nomDonateur;

  const ProfilDonateurPage({
    super.key,
    required this.donateurId,
    required this.nomDonateur,
  });

  @override
  ConsumerState<ProfilDonateurPage> createState() => _ProfilDonateurPageState();
}

class _ProfilDonateurPageState extends ConsumerState<ProfilDonateurPage> {
  String _obtenirInitiales(String prenom, String nom) {
    final p = prenom.trim().isNotEmpty ? prenom.trim()[0].toUpperCase() : '';
    final n = nom.trim().isNotEmpty ? nom.trim()[0].toUpperCase() : '';
    final res = '$p$n';
    return res.isNotEmpty ? res : 'D';
  }

  Widget _construireAvatarImage(String? photoUrl, String initiales) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        return Image.network(
          photoUrl,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
        );
      }
      if (!kIsWeb) {
        final fichier = File(photoUrl);
        if (fichier.existsSync()) {
          return Image.file(
            fichier,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
          );
        }
      }
      // Image distante sur le backend Spring Boot (/uploads/photos/...)
      final urlDistante = photoUrl.startsWith('/uploads')
          ? '${AuthRepository.baseUrl}$photoUrl'
          : '${AuthRepository.baseUrl}/uploads/photos/$photoUrl';
      return Image.network(
        urlDistante,
        width: 76,
        height: 76,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
      );
    }
    return _avatarInitiales(initiales);
  }

  Widget _avatarInitiales(String initiales) {
    return Container(
      color: const Color(0xFFEAE8E2),
      child: Center(
        child: Text(
          initiales,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: CouleursApp.vert,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _gererPhotoProfil(BuildContext context, Donateur? d) async {
    final aDejaUnePhoto = d?.photo != null && d!.photo!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: CouleursApp.blanc,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Photo de profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 14),

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CouleursApp.vert.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: CouleursApp.vert),
                  ),
                  title: const Text(
                    'Choisir depuis la galerie',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Sélectionner une photo sur votre téléphone',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final fichiers = await FilePicker.pickFiles(
                        type: FileType.image,
                      );
                      if (fichiers.isNotEmpty) {
                        final path = fichiers.first.path;
                        if (path != null && path.isNotEmpty) {
                          final repo = ref.read(donateurRepositoryProvider);
                          await repo.enregistrerPhotoProfil(
                            donateurId: widget.donateurId,
                            cheminFichier: path,
                          );
                          ref.invalidate(donateurProvider(widget.donateurId));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo de profil mise à jour avec succès !'),
                              backgroundColor: CouleursApp.vert,
                            ),
                          );
                        }
                      }
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Impossible d'accéder à la photo."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),

                if (aDejaUnePhoto)
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                    title: const Text(
                      'Supprimer la photo actuelle',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                    subtitle: const Text(
                      "Revenir à l'affichage des initiales",
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final repo = ref.read(donateurRepositoryProvider);
                      await repo.supprimerPhotoProfil(widget.donateurId);
                      ref.invalidate(donateurProvider(widget.donateurId));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo de profil supprimée.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donsFinanciersAsync =
        ref.watch(donsFinanciersDonateurControllerProvider(widget.donateurId));
    final badgesAsync = ref.watch(badgesActuelsProvider(widget.donateurId));
    final donateurAsync = ref.watch(donateurProvider(widget.donateurId));

    final donateur = donateurAsync.value;
    final nomAffiche = donateur != null && donateur.nomComplet.isNotEmpty
        ? donateur.nomComplet
        : widget.nomDonateur;
    final telephone = donateur?.telephone ?? '';
    final initiales = _obtenirInitiales(
      donateur?.prenom ?? widget.nomDonateur,
      donateur?.nom ?? '',
    );
    final photoUrl = donateur?.photo;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.invalidate(
              donsFinanciersDonateurControllerProvider(widget.donateurId),
            );
            ref.invalidate(badgesActuelsProvider(widget.donateurId));
            ref.invalidate(donateurProvider(widget.donateurId));

            await Future.wait([
              ref.read(
                donsFinanciersDonateurControllerProvider(widget.donateurId).future,
              ),
              ref.read(badgesActuelsProvider(widget.donateurId).future),
              ref.read(donateurProvider(widget.donateurId).future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const Center(
                child: Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Informations et photo du donateur
              Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _gererPhotoProfil(context, donateur),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: CouleursApp.vert.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CouleursApp.vert.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _construireAvatarImage(photoUrl, initiales),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _gererPhotoProfil(context, donateur),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: CouleursApp.vert,
                              shape: BoxShape.circle,
                              border: Border.all(color: CouleursApp.blanc, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: CouleursApp.blanc,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomAffiche,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: CouleursApp.noir,
                          ),
                        ),
                        if (telephone.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            telephone,
                            style: TextStyle(
                              fontSize: 13,
                              color: CouleursApp.noir.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: CouleursApp.vert.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Donateur',
                            style: TextStyle(
                              color: CouleursApp.vert,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Statistiques des dons financiers
              donsFinanciersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger les dons financiers.',
                ),
                data: (dons) {
                  final total = dons.fold<double>(
                    0,
                        (somme, don) => somme + don.montant,
                  );

                  return _statistiquesFinancieres(
                    nombreDons: dons.length,
                    montantTotal: total,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Badges du semestre actuel
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mon badge actuel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.noir,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: CouleursApp.fond,
                            builder: (_) => _HistoriqueBadges(
                              donateurId: widget.donateurId,
                            ),
                          );
                        },
                        child: const Text(
                          'Voir l’historique',
                          style: TextStyle(
                            color: CouleursApp.vert,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Attribution semestrielle (S1 / S2) : calculée selon vos dons financiers et matériels.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777777),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              badgesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger le badge.',
                ),
                data: (badges) {
                  if (badges.isEmpty) {
                    return _carteAucunBadgeActuel(badges);
                  }

                  // Identifier le badge actuellement obtenu le plus élevé pour ce semestre
                  final badgesObtenus = badges.where((b) => b.obtenu).toList();
                  final badgeActuel =
                      badgesObtenus.isNotEmpty ? badgesObtenus.last : null;

                  if (badgeActuel != null) {
                    return _carteBadgeActuel(badgeActuel);
                  }

                  return _carteAucunBadgeActuel(badges);
                },
              ),

              const SizedBox(height: 28),

              // Activité mensuelle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mon activité',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.noir,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EFE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Cette année',
                      style: TextStyle(
                        fontSize: 11,
                        color: CouleursApp.vert,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              donsFinanciersAsync.when(
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _messageErreur(
                  'Impossible de charger le graphique.',
                ),
                data: (dons) => _graphiqueMensuel(dons),
              ),

              const SizedBox(height: 32),

              // Bouton "Se déconnecter"
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _deconnecter(context),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFFFCDD2),
                      width: 1.5,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deconnecter(BuildContext context) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmer != true) return;

    await AuthRepository().deconnexion();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConnexionPage()),
      (route) => false,
    );
  }

  Widget _statistiquesFinancieres({
    required int nombreDons,
    required double montantTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _statistique(
              'Dons effectués',
              '$nombreDons',
              Icons.volunteer_activism_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 55,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _statistique(
              'Total des dons',
              '${_montant(montantTotal)} FCFA',
              Icons.account_balance_wallet_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistique(String titre, String valeur, IconData icone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icone, color: CouleursApp.vert, size: 24),
          const SizedBox(height: 8),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            valeur,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteBadgeActuel(BadgeDonateurModel badge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CouleursApp.jaune.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CouleursApp.jaune.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: WidgetImageBadge(
                badge: badge,
                taille: 44,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: CouleursApp.vert.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge.semestreCourt.isNotEmpty
                            ? 'Badge actif · ${badge.semestreCourt}'
                            : 'Badge actif',
                        style: const TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  badge.nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  badge.libelleSemestre.isNotEmpty
                      ? badge.libelleSemestre
                      : 'Attribué pour ce semestre',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteAucunBadgeActuel(List<BadgeDonateurModel> badges) {
    final prochain = badges.isNotEmpty ? badges.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aucun badge ce semestre',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prochain != null
                      ? 'Faites un don pour débloquer le badge « ${prochain.nom} ».'
                      : 'Vos dons semestriels vous permettent de débloquer vos badges.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphiqueMensuel(List<DonFinancier> dons) {
    final maintenant = DateTime.now();
    final montants = List<double>.filled(12, 0);

    for (final don in dons) {
      final date = don.dateDon;

      if (date != null && date.year == maintenant.year) {
        montants[date.month - 1] += don.montant;
      }
    }

    final mois = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];

    final maximum = montants.fold<double>(
      0,
          (max, valeur) => valeur > max ? valeur : max,
    );

    final maxY = maximum <= 0 ? 100.0 : maximum * 1.2;

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_montant(maximum)} FCFA',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${mois[group.x]}\\n${_montant(rod.toY)} FCFA',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) => Text(
                        _abregerMontant(value),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= 12) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            mois[index],
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(12, (index) {
                  final montant = montants[index];
                  final moisActif = index == maintenant.month - 1;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: montant,
                        width: 13,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        color: moisActif
                            ? CouleursApp.vert
                            : CouleursApp.jaune,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carteMessage(String message, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: CouleursApp.vert),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _messageErreur(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  String _montant(double montant) {
    return montant.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );
  }

  String _abregerMontant(double montant) {
    if (montant >= 1000000) {
      return '${(montant / 1000000).toStringAsFixed(1)}M';
    }

    if (montant >= 1000) {
      return '${(montant / 1000).toStringAsFixed(0)}K';
    }

    return montant.toStringAsFixed(0);
  }
}

// Historique des badges du donateur.
class _HistoriqueBadges extends ConsumerWidget {
  final int donateurId;

  const _HistoriqueBadges({
    required this.donateurId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historiqueAsync = ref.watch(
      historiqueBadgesProvider(donateurId),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique de mes badges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Attribution semestrielle : vos badges sont calculés 2 fois par an (S1 : Janvier - Juin, S2 : Juillet - Décembre) selon l’ensemble de vos dons.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: historiqueAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => const Text(
                  'Impossible de charger l’historique des badges.',
                ),
                data: (badges) {
                  if (badges.isEmpty) {
                    return const Text(
                      'Aucun badge dans votre historique.',
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: badges.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final badge = badges[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: WidgetImageBadge(
                          badge: badge,
                          taille: 40,
                        ),
                        title: Text(
                          badge.nom,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          badge.libelleSemestre.isNotEmpty
                              ? badge.libelleSemestre
                              : [
                                  if (badge.semestre != null) badge.semestre!,
                                  if (badge.annee != null) '${badge.annee}',
                                ].join(' · '),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CouleursApp.vert.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: CouleursApp.vert,
                                size: 15,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Obtenu',
                                style: TextStyle(
                                  color: CouleursApp.vert,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget dédié pour afficher l'image du badge (avec support Spring Boot /uploads/badges/).
class WidgetImageBadge extends StatelessWidget {
  final BadgeDonateurModel badge;
  final double taille;

  const WidgetImageBadge({
    super.key,
    required this.badge,
    this.taille = 42,
  });

  @override
  Widget build(BuildContext context) {
    final url = badge.urlComplete(AuthRepository.baseUrl);

    Widget image;
    if (url != null && url.isNotEmpty) {
      image = Image.network(
        url,
        width: taille,
        height: taille,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: taille,
            height: taille,
            child: Center(
              child: SizedBox(
                width: taille * 0.45,
                height: taille * 0.45,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CouleursApp.jaune,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            '[BADGE] Erreur chargement image pour ${badge.nom} ($url) : $error',
          );
          return Icon(
            Icons.workspace_premium,
            size: taille,
            color: badge.obtenu ? CouleursApp.jaune : Colors.grey,
          );
        },
      );
    } else {
      image = Icon(
        Icons.workspace_premium,
        size: taille,
        color: badge.obtenu ? CouleursApp.jaune : Colors.grey,
      );
    }

    if (!badge.obtenu) {
      return Opacity(
        opacity: 0.45,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.saturation,
          ),
          child: image,
        ),
      );
    }

    return image;
  }
}
