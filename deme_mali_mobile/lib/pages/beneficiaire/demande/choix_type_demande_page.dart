import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';
import 'demande_aide_stepper_page.dart';

/// Écran affiché dès que l'utilisateur clique sur « Faire une demande d'aide » :
/// il choisit entre une demande financière et une demande matérielle.
class ChoixTypeDemandePage extends StatelessWidget {
  const ChoixTypeDemandePage({super.key});

  // Ouvre le formulaire en remplaçant cet écran : après l'envoi (ou un retour
  // depuis l'étape 1), l'utilisateur retrouve directement l'accueil.
  void _ouvrirFormulaire(BuildContext context, String typeDemandeAide) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DemandeAideStepperPage(typeDemandeAide: typeDemandeAide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour circulaire blanc
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: CouleursApp.noir,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Quel type d’aide\nsouhaitez-vous ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: CouleursApp.noir,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez la nature de votre demande.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 28),

              _CarteChoix(
                icone: Icons.account_balance_wallet_outlined,
                couleurFondIcone: const Color(0xFFE8F5EE),
                couleurIcone: CouleursApp.vert,
                titre: 'Demande financière',
                description: 'Recevoir une aide en argent pour couvrir un besoin.',
                onTap: () => _ouvrirFormulaire(context, 'FINANCIERE'),
              ),
              const SizedBox(height: 16),
              _CarteChoix(
                icone: Icons.inventory_2_outlined,
                couleurFondIcone: CouleursApp.jaune,
                couleurIcone: CouleursApp.noir,
                titre: 'Demande matérielle',
                description:
                    'Demander des articles : vivres, vêtements, matériel...',
                onTap: () => _ouvrirFormulaire(context, 'MATERIELLE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Grande carte cliquable représentant un choix
class _CarteChoix extends StatelessWidget {
  const _CarteChoix({
    required this.icone,
    required this.couleurFondIcone,
    required this.couleurIcone,
    required this.titre,
    required this.description,
    required this.onTap,
  });

  final IconData icone;
  final Color couleurFondIcone;
  final Color couleurIcone;
  final String titre;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: couleurFondIcone,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icone, color: couleurIcone, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.noir,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.55),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: CouleursApp.vert,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
