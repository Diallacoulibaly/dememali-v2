import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../models/beneficiaire.dart';
import '../../../repositories/auth_repository.dart';
import '../../../styles/couleurs.dart';
import '../../authentification/connexion.dart';

/// Page "Mon profil" du bénéficiaire.
/// Entièrement dynamique avec récupération des données du bénéficiaire et de son organisation partenaire.
class MonProfilPage extends ConsumerStatefulWidget {
  const MonProfilPage({super.key});

  @override
  ConsumerState<MonProfilPage> createState() => _MonProfilPageState();
}
class _MonProfilPageState extends ConsumerState<MonProfilPage> {
  // Déconnexion de l'utilisateur
  Future<void> _deconnecter() async {
    final repo = ref.read(demandeAideRepositoryProvider);
    await repo.stockage.deleteAll();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ConnexionPage()),
      (route) => false,
    );
  }

  String _obtenirInitiales(String prenom, String nom) {
    final p = prenom.trim().isNotEmpty ? prenom.trim()[0].toUpperCase() : '';
    final n = nom.trim().isNotEmpty ? nom.trim()[0].toUpperCase() : '';
    final res = '$p$n';
    return res.isNotEmpty ? res : 'B';
  }

  @override
  Widget build(BuildContext context) {
    final profilAsync = ref.watch(profilBeneficiaireProvider);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.invalidate(profilBeneficiaireProvider);
            await ref.read(profilBeneficiaireProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Barre supérieure : Bouton retour + Titre centré
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(ongletActifBeneficiaireProvider.notifier).state = 0;
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CouleursApp.blanc,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, color: CouleursApp.noir, size: 20),
                      ),
                    ),
                    const Text(
                      'Mon profil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.noir,
                      ),
                    ),
                    const SizedBox(width: 44), // Pour équilibrer le bouton retour
                  ],
                ),

                const SizedBox(height: 24),

                // 2. Gestion des données dynamiques
                profilAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(color: CouleursApp.vert),
                    ),
                  ),
                  error: (err, stack) => _buildBlocErreur(),
                  data: (beneficiaire) {
                    final b = beneficiaire ??
                        const Beneficiaire(
                          id: 0,
                          nom: 'Utilisateur',
                          prenom: '',
                        );
                    return _buildCorpsProfil(context, b);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construireAvatarImage(Beneficiaire b, String initiales) {
    if (b.photoUrl != null && b.photoUrl!.isNotEmpty) {
      final photo = b.photoUrl!;
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        return Image.network(
          photo,
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
        );
      }
      if (!kIsWeb) {
        final fichier = File(photo);
        if (fichier.existsSync()) {
          return Image.file(
            fichier,
            width: 104,
            height: 104,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
          );
        }
      }
      // Image distante sur le backend Spring Boot (nom de fichier ou chemin relatif)
      final urlDistante = photo.startsWith('/uploads')
          ? '${AuthRepository.baseUrl}$photo'
          : '${AuthRepository.baseUrl}/uploads/photos/$photo';
      return Image.network(
        urlDistante,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarInitiales(initiales),
      );
    }
    return _avatarInitiales(initiales);
  }

  Widget _avatarInitiales(String initiales) {
    return Center(
      child: Text(
        initiales,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: CouleursApp.vert,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Future<void> _gererPhotoProfil(BuildContext context, Beneficiaire b) async {
    final aDejaUnePhoto = b.photoUrl != null && b.photoUrl!.isNotEmpty;

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
                          final repo = ref.read(demandeAideRepositoryProvider);
                          await repo.enregistrerPhotoProfil(
                            beneficiaireId: b.id,
                            cheminFichier: path,
                          );
                          ref.invalidate(profilBeneficiaireProvider);
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
                          content: Text('Impossible d\'accéder à la photo.'),
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
                      'Revenir à l\'affichage des initiales',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      final repo = ref.read(demandeAideRepositoryProvider);
                      await repo.supprimerPhotoProfil(b.id);
                      ref.invalidate(profilBeneficiaireProvider);
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

  Widget _buildCorpsProfil(BuildContext context, Beneficiaire b) {
    final initiales = _obtenirInitiales(b.prenom, b.nom);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar circulaire avec initiales et badge caméra cliquables
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => _gererPhotoProfil(context, b),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: CouleursApp.vert.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CouleursApp.vert.withValues(alpha: 0.25),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: _construireAvatarImage(b, initiales),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: InkWell(
                  onTap: () => _gererPhotoProfil(context, b),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
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
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Nom complet
        Text(
          b.nomComplet,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: CouleursApp.noir,
          ),
        ),
        const SizedBox(height: 6),

        // Badge Type Bénéficiaire (Particulier)
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              b.typeBeneficiaireAffiche,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bouton bordé jaune "Modifier mon profil"
        OutlinedButton.icon(
          onPressed: () => _ouvrirModifierProfil(context, b),
          icon: const Icon(Icons.edit_outlined, color: CouleursApp.jaune, size: 18),
          label: const Text(
            'Modifier mon profil',
            style: TextStyle(
              color: CouleursApp.jaune,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: CouleursApp.jaune, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
          ),
        ),

        const SizedBox(height: 24),

        // Carte "Informations personnelles"
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                ),
              ),
              const SizedBox(height: 18),

              // Ligne Nom
              _buildLigneInfo(
                icone: Icons.person_outline,
                titre: 'Nom de famille',
                valeur: b.nom.isNotEmpty ? b.nom : 'Non renseigné',
              ),
              const SizedBox(height: 14),

              // Ligne Prénom
              _buildLigneInfo(
                icone: Icons.badge_outlined,
                titre: 'Prénom',
                valeur: b.prenom.isNotEmpty ? b.prenom : 'Non renseigné',
              ),
              const SizedBox(height: 14),

              // Ligne Téléphone
              _buildLigneInfo(
                icone: Icons.phone_outlined,
                titre: 'Téléphone',
                valeur: b.telephone != null && b.telephone!.isNotEmpty
                    ? b.telephone!
                    : 'Non renseigné',
              ),

              if (b.email != null && b.email!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildLigneInfo(
                  icone: Icons.alternate_email,
                  titre: 'Email',
                  valeur: b.email!,
                ),
              ],

              if ((b.ville != null && b.ville!.isNotEmpty) ||
                  (b.adresse != null && b.adresse!.isNotEmpty)) ...[
                const SizedBox(height: 14),
                _buildLigneInfo(
                  icone: Icons.location_on_outlined,
                  titre: 'Localisation',
                  valeur: [
                    if (b.adresse != null && b.adresse!.isNotEmpty) b.adresse,
                    if (b.ville != null && b.ville!.isNotEmpty) b.ville,
                  ].join(', '),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Section "Organisation partenaire associée"
        Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Mon accompagnement',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: CouleursApp.noir,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Carte Organisation partenaire
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CouleursApp.vert.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      size: 26,
                      color: CouleursApp.vert,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.nomOrganisationAffiche,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.noir,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.typeOrganisation != null && b.typeOrganisation!.isNotEmpty
                              ? b.typeOrganisation!
                              : 'Organisation partenaire référente',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Détails complémentaires sur l'organisation partenaire
              if (b.telephoneOrganisation != null ||
                  b.emailOrganisation != null ||
                  b.villeOrganisation != null) ...[
                const SizedBox(height: 14),
                Divider(color: Colors.black.withValues(alpha: 0.06)),
                const SizedBox(height: 10),

                if (b.telephoneOrganisation != null && b.telephoneOrganisation!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.phone, size: 15, color: Colors.black.withValues(alpha: 0.45)),
                      const SizedBox(width: 8),
                      Text(
                        b.telephoneOrganisation!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (b.emailOrganisation != null && b.emailOrganisation!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.mail_outline, size: 15, color: Colors.black.withValues(alpha: 0.45)),
                      const SizedBox(width: 8),
                      Text(
                        b.emailOrganisation!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                if (b.villeOrganisation != null && b.villeOrganisation!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 15, color: Colors.black.withValues(alpha: 0.45)),
                      const SizedBox(width: 8),
                      Text(
                        b.adresseOrganisation != null && b.adresseOrganisation!.isNotEmpty
                            ? '${b.adresseOrganisation}, ${b.villeOrganisation}'
                            : b.villeOrganisation!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Bouton "Se déconnecter"
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _deconnecter,
            icon: const Icon(Icons.logout, color: CouleursApp.jaune, size: 20),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(
                color: CouleursApp.jaune,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CouleursApp.jaune, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Méthode d'aide pour une ligne d'information
  Widget _buildLigneInfo({
    required IconData icone,
    required String titre,
    required String valeur,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icone, color: CouleursApp.vert, size: 18),
            const SizedBox(width: 10),
            Text(
              titre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CouleursApp.noir,
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            valeur,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocErreur() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 10),
          const Text(
            'Impossible de charger vos informations de profil.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => ref.invalidate(profilBeneficiaireProvider),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: CouleursApp.vert, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal d'édition du profil
  void _ouvrirModifierProfil(BuildContext context, Beneficiaire b) {
    final nomCtrl = TextEditingController(text: b.nom);
    final prenomCtrl = TextEditingController(text: b.prenom);
    final telCtrl = TextEditingController(text: b.telephone ?? '');
    final villeCtrl = TextEditingController(text: b.ville ?? '');
    final adresseCtrl = TextEditingController(text: b.adresse ?? '');

    bool enCours = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              18,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: CouleursApp.blanc,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poignée supérieure
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Modifier mon profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: CouleursApp.noir,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _champEdition(
                    label: 'Nom de famille',
                    controller: nomCtrl,
                    icone: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),

                  _champEdition(
                    label: 'Prénom',
                    controller: prenomCtrl,
                    icone: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),

                  _champEdition(
                    label: 'Téléphone',
                    controller: telCtrl,
                    icone: Icons.phone_outlined,
                    clavier: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _champEdition(
                    label: 'Ville / Quartier',
                    controller: villeCtrl,
                    icone: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 12),

                  _champEdition(
                    label: 'Adresse exacte',
                    controller: adresseCtrl,
                    icone: Icons.place_outlined,
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: enCours
                          ? null
                          : () async {
                              final nom = nomCtrl.text.trim();
                              final prenom = prenomCtrl.text.trim();
                              final tel = telCtrl.text.trim();

                              if (nom.isEmpty || prenom.isEmpty || tel.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Veuillez remplir au moins le nom, le prénom et le téléphone.'),
                                  ),
                                );
                                return;
                              }

                              setModalState(() => enCours = true);

                              final repo = ref.read(demandeAideRepositoryProvider);
                              final ok = await repo.modifierProfil(
                                userId: b.id,
                                nom: nom,
                                prenom: prenom,
                                telephone: tel,
                                ville: villeCtrl.text.trim(),
                                adresse: adresseCtrl.text.trim(),
                              );

                              if (!context.mounted) return;
                              setModalState(() => enCours = false);
                              Navigator.of(context).pop();

                              if (ok) {
                                ref.invalidate(profilBeneficiaireProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profil mis à jour avec succès !'),
                                    backgroundColor: CouleursApp.vert,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: enCours
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: CouleursApp.blanc,
                              ),
                            )
                          : const Text(
                              'Enregistrer les modifications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _champEdition({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    TextInputType clavier = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: CouleursApp.noir,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: clavier,
          decoration: InputDecoration(
            prefixIcon: Icon(icone, size: 20, color: CouleursApp.vert),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: CouleursApp.vert, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

