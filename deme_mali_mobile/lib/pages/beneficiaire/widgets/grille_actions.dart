import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';
import 'carte_action.dart';

// Grille 2x2 des 4 cartes d'action de l'accueil
class GrilleActions extends StatelessWidget {
  const GrilleActions({
    super.key,
    required this.onDemanderAide,
    required this.onMesDemandes,
    required this.onSuiviAides,
    required this.onAidesRecues,
  });

  final VoidCallback onDemanderAide;
  final VoidCallback onMesDemandes;
  final VoidCallback onSuiviAides;
  final VoidCallback onAidesRecues;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte 1 : Demander une aide
            Expanded(
              child: CarteAction(
                icone: Icons.volunteer_activism_outlined,
                couleurFondIcone: const Color(0xFFE8F5EE),
                couleurIcone: CouleursApp.vert,
                titre: 'Demander une aide',
                sousTitre: 'Faire une demande',
                onTap: onDemanderAide,
              ),
            ),
            const SizedBox(width: 14),
            // Carte 2 : Mes demandes
            Expanded(
              child: CarteAction(
                icone: Icons.description_outlined,
                couleurFondIcone: CouleursApp.jaune,
                couleurIcone: CouleursApp.noir,
                titre: 'Mes demandes',
                sousTitre: 'La liste de tes demandes aides',
                onTap: onMesDemandes,
              ),
            ),
          ],
        )),
        const SizedBox(height: 14),
        IntrinsicHeight(child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte 3 : Suivre mes aides
            Expanded(
              child: CarteAction(
                icone: Icons.search_rounded,
                couleurFondIcone: const Color(0xFFE8F5EE),
                couleurIcone: CouleursApp.vert,
                titre: 'Suivre mes aides',
                sousTitre: 'Voir l’avancement',
                onTap: onSuiviAides,
              ),
            ),
            const SizedBox(width: 14),
            // Carte 4 : Mes aides reçus
            Expanded(
              child: CarteAction(
                icone: Icons.card_giftcard_rounded,
                couleurFondIcone: CouleursApp.jaune,
                couleurIcone: CouleursApp.noir,
                titre: 'Mes aides reçus',
                sousTitre: 'Retrouvez vos aides déjà reçues.',
                onTap: onAidesRecues,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
