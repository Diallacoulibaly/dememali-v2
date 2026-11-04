import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/accueil_beneficiaire_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../styles/couleurs.dart';
import 'aides_recues/mes_aides_recues_page.dart';
import 'demande/choix_type_demande_page.dart';
import 'mes_demandes/mes_demandes_page.dart';
import 'notifications/notifications_page.dart';
import 'profil/mon_profil_page.dart';
import 'suivi/suivre_aides_page.dart';
import 'widgets/barre_navigation_beneficiaire.dart';
import 'widgets/entete_beneficiaire.dart';
import 'widgets/grille_actions.dart';

class AccueilBeneficiairePage extends ConsumerStatefulWidget {
  const AccueilBeneficiairePage({
    super.key,
    this.prenomBeneficiaire = '',
    this.onDemanderAide,
    this.onMesDemandes,
    this.onSuiviAides,
    this.onAidesRecues,
  });

  final String prenomBeneficiaire;
  final VoidCallback? onDemanderAide, onMesDemandes, onSuiviAides, onAidesRecues;

  @override
  ConsumerState<AccueilBeneficiairePage> createState() =>
      _AccueilBeneficiairePageState();
}

class _AccueilBeneficiairePageState
    extends ConsumerState<AccueilBeneficiairePage> {
  @override
  void initState() {
    super.initState();
    // Charger immédiatement les notifications du bénéficiaire
    Future.microtask(() {
      ref.read(notificationsNotifierProvider.notifier).charger();
    });
  }

  void _ouvrirNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  void _ouvrirDemandeAide(BuildContext context) {
    if (widget.onDemanderAide != null) {
      widget.onDemanderAide!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChoixTypeDemandePage()),
      );
    }
  }

  void _ouvrirMesDemandes(BuildContext context) {
    if (widget.onMesDemandes != null) {
      widget.onMesDemandes!();
    } else {
      ref.read(ongletActifBeneficiaireProvider.notifier).state = 1;
    }
  }

  void _ouvrirSuiviAides(BuildContext context) {
    if (widget.onSuiviAides != null) {
      widget.onSuiviAides!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SuivreAidesPage()),
      );
    }
  }

  void _ouvrirAidesRecues(BuildContext context) {
    if (widget.onAidesRecues != null) {
      widget.onAidesRecues!();
    } else {
      ref.read(ongletActifBeneficiaireProvider.notifier).state = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lire l'onglet actif avec Riverpod
    final selectedIndex = ref.watch(ongletActifBeneficiaireProvider);

    // 2. Déterminer si le bénéficiaire est un particulier ou une structure
    final profilAsync = ref.watch(profilBeneficiaireProvider);
    final bool estStructure =
        profilAsync.value?.typeBeneficiaire?.toUpperCase() == 'STRUCTURE';
    final String nomStructure = profilAsync.value?.nomStructure ?? '';

    final String nomAffiche = estStructure && nomStructure.isNotEmpty
        ? nomStructure
        : (profilAsync.value?.prenom.isNotEmpty == true
            ? profilAsync.value!.prenom
            : (widget.prenomBeneficiaire.isNotEmpty
                ? widget.prenomBeneficiaire
                : (estStructure ? 'Structure' : 'Bénéficiaire')));

    // 3. Choisir l'écran à afficher selon l'onglet sélectionné
    Widget corps;
    if (selectedIndex == 1) {
      corps = const MesDemandesPage();
    } else if (selectedIndex == 2) {
      corps = const MesAidesRecuesPage();
    } else if (selectedIndex == 3) {
      corps = const MonProfilPage();
    } else {
      corps = _buildCorpsAccueil(
        context,
        nomAffiche: nomAffiche,
        estStructure: estStructure,
      );
    }

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedIndex != 0) {
          ref.read(ongletActifBeneficiaireProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        backgroundColor: CouleursApp.fond,
        body: corps,
        bottomNavigationBar: const BarreNavigationBeneficiaire(),
      ),
    );
  }

  // Contenu principal de l'onglet 0 (Accueil / Home)
  Widget _buildCorpsAccueil(
    BuildContext context, {
    required String nomAffiche,
    required bool estStructure,
  }) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. En-tête : Logo Dèmè Mali + Cloche notification dynamique avec badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: EnteteBeneficiaire(
              onNotificationTap: () => _ouvrirNotifications(context),
            ),
          ),

          const SizedBox(height: 20),

          // Contenu défilable
          Expanded(
            child: RefreshIndicator(
              color: CouleursApp.vert,
              onRefresh: () async {
                ref.invalidate(mesDemandesBeneficiaireProvider);
                ref.invalidate(profilBeneficiaireProvider);
                ref.read(notificationsNotifierProvider.notifier).charger();
                await ref.read(mesDemandesBeneficiaireProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Message de bienvenue adapté
                    Text(
                      'Bonjour $nomAffiche',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.noir,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      estStructure
                          ? 'Bienvenue dans votre espace structure.'
                          : 'Bienvenue dans votre espace bénéficiaire.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 3. Bouton principal : "+ Faire une demande d'aide"
                    _buildBoutonFaireDemande(context),

                    const SizedBox(height: 26),

                    // 4. Titre de section "Que souhaitez-vous faire ?"
                    const Text(
                      'Que souhaitez-vous faire ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.noir,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Grille 2x2 des 4 cartes d'actions
                    GrilleActions(
                      onDemanderAide: () => _ouvrirDemandeAide(context),
                      onMesDemandes: () => _ouvrirMesDemandes(context),
                      onSuiviAides: () => _ouvrirSuiviAides(context),
                      onAidesRecues: () => _ouvrirAidesRecues(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bouton vert principal "+ Faire une demande d'aide"
  Widget _buildBoutonFaireDemande(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _ouvrirDemandeAide(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: 62,
          decoration: BoxDecoration(
            color: CouleursApp.vert,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CouleursApp.vert.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: CouleursApp.blanc, size: 24),
              SizedBox(width: 8),
              Text(
                'Faire une demande d’aide',
                style: TextStyle(
                  color: CouleursApp.blanc,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
