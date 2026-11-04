
import 'package:flutter/material.dart';

import '/styles/couleurs.dart';
import 'package:deme_mali_mobile/pages/navigation_donateur_page.dart';
class DonReussiPage extends StatelessWidget {
  final double montant;
  final String modePaiement;
  final String prenom;
  final int donateurId;

  const DonReussiPage({
    super.key,
    required this.montant,
    required this.modePaiement,
    required this.prenom,
    required this.donateurId,
  });

  String get montantFormate {
    return montant
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Icône de confirmation
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 76,
                  color: CouleursApp.vert,
                ),
              ),

              const SizedBox(height: 28),

              // Message de réussite
              const Text(
                'Merci pour votre don !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.vert,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Votre générosité contribue à améliorer '
                    'la vie de ceux qui en ont besoin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 32),

              // Récapitulatif du don
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CouleursApp.vert.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Montant du don',
                      style: TextStyle(
                        fontSize: 14,
                        color: CouleursApp.noir,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '$montantFormate FCFA',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.vert,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Divider(
                      color: CouleursApp.noir.withValues(alpha: 0.10),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.payment,
                          color: CouleursApp.vert,
                          size: 22,
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Text(
                            'Mode de paiement',
                            style: TextStyle(
                              fontSize: 14,
                              color: CouleursApp.noir,
                            ),
                          ),
                        ),

                        Flexible(
                          child: Text(
                            modePaiement,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CouleursApp.noir,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const Spacer(),

              // Retour à l'accueil
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => NavigationDonateurPage(
                          prenom: prenom,
                          donateurId: donateurId,
                        ),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Retour à l'accueil",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
