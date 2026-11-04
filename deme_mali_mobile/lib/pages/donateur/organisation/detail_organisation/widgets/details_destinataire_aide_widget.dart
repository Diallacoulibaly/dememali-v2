
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:deme_mali_mobile/models/aide_distribuee.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';
import 'package:deme_mali_mobile/controllers/beneficiaire_controller.dart';
import 'package:deme_mali_mobile/controllers/demande_aide_controller.dart';

class DetailsDestinataireAideWidget extends ConsumerWidget {
  const DetailsDestinataireAideWidget({
    super.key,
    required this.aide,
    this.preuve,
  });

  final AideDistribuee aide;
  final Widget? preuve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Priorité à la demande associée.
    if (aide.demandeAideId != null) {
      final demandeAsync = ref.watch(
        demandeAideDetailProvider(aide.demandeAideId!),
      );

      return demandeAsync.when(
        loading: () => const _ChargementInformation(),
        error: (error, stackTrace) => const _MessageInformation(
          message: 'Impossible de charger les informations de la demande.',
        ),
        data: (demande) {
          final estMaterielle = demande.estMaterielle;
          final type = estMaterielle ? 'Matérielle' : 'Financière';

          return _carte(
            contenu: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _icone(
                  estMaterielle
                      ? Icons.inventory_2_outlined
                      : Icons.volunteer_activism_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEMANDE ASSOCIÉE',
                        style: TextStyle(
                          color: CouleursApp.noir.withValues(alpha: 0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        demande.titre.isNotEmpty
                            ? demande.titre
                            : 'Demande sans titre',
                        style: const TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BadgeTypeAide(
                        type: type,
                        estMaterielle: estMaterielle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Sans demande associée : afficher uniquement le nom du bénéficiaire.
    if (aide.beneficiaireId != null) {
      final beneficiaireAsync = ref.watch(
        beneficiaireDetailProvider(aide.beneficiaireId!),
      );

      return beneficiaireAsync.when(
        loading: () => const _ChargementInformation(),
        error: (error, stackTrace) => const _MessageInformation(
          message: 'Impossible de charger le bénéficiaire.',
        ),
        data: (beneficiaire) {
          final nomComplet =
          '${beneficiaire.prenom} ${beneficiaire.nom}'.trim();

          return _carte(
            contenu: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _icone(Icons.person_outline_rounded),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BÉNÉFICIAIRE',
                        style: TextStyle(
                          color: CouleursApp.noir.withValues(alpha: 0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nomComplet.isNotEmpty
                            ? nomComplet
                            : 'Nom non renseigné',
                        style: const TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return const _MessageInformation(
      message: 'Aucune demande ni aucun bénéficiaire associé à cette aide.',
    );
  }

  Widget _carte({required Widget contenu}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CouleursApp.noir.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preuve en haut de la carte, si elle est fournie.
          if (preuve != null)
            SizedBox(
              width: double.infinity,
              height: 220,
              child: preuve!,
            ),

          // Informations en dessous.
          Padding(
            padding: const EdgeInsets.all(16),
            child: contenu,
          ),
        ],
      ),
    );
  }

  Widget _icone(IconData icone) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: CouleursApp.vert.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icone,
        color: CouleursApp.vert,
        size: 25,
      ),
    );
  }
}

class _BadgeTypeAide extends StatelessWidget {
  const _BadgeTypeAide({
    required this.type,
    required this.estMaterielle,
  });

  final String type;
  final bool estMaterielle;

  @override
  Widget build(BuildContext context) {
    final couleur = estMaterielle
        ? CouleursApp.vert
        : const Color(0xFFF7B500);

    final couleurTexte = estMaterielle
        ? CouleursApp.vert
        : const Color(0xFF8A6200);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estMaterielle
                ? Icons.inventory_2_outlined
                : Icons.account_balance_wallet_outlined,
            size: 15,
            color: couleurTexte,
          ),
          const SizedBox(width: 7),
          Text(
            'Aide $type',
            style: TextStyle(
              color: couleurTexte,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChargementInformation extends StatelessWidget {
  const _ChargementInformation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 19,
            height: 19,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: CouleursApp.vert,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Chargement des informations...',
            style: TextStyle(
              color: CouleursApp.noir,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageInformation extends StatelessWidget {
  const _MessageInformation({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CouleursApp.noir.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: CouleursApp.noir.withValues(alpha: 0.70),
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}
