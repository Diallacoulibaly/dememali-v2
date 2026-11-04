
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';
import 'don_financier/don_financier_page.dart';
import 'don_materiel/don_materiel_general_page.dart';

class FaireUnDonPage extends StatelessWidget {
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;
  final String prenom;

  const FaireUnDonPage({
    super.key,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: CouleursApp.blanc,
                        foregroundColor: CouleursApp.noir,
                        side: BorderSide(
                          color: CouleursApp.noir.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Faire un don',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 24),

                // Texte d'introduction
                const Text(
                  'Choisissez le type de don que vous souhaitez '
                      'offrir pour soutenir ceux qui en ont besoin.',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Carte don financier
                _carteTypeDon(
                  contexte: context,
                  icone: Icons.account_balance_wallet_outlined,
                  titre: 'Don financier',
                  description:
                  'Offrez une contribution financière pour soutenir '
                      'les besoins des bénéficiaires.',
                  texteBouton: 'Faire un don',
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonFinancierPage(
                          donateurId: donateurId,
                          demandeAideId: demandeAideId,
                          organisationPartenaireId:
                          organisationPartenaireId,
                          prenom: prenom,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Carte don matériel
                _carteTypeDon(
                  contexte: context,
                  icone: Icons.inventory_2_outlined,
                  titre: 'Don matériel',
                  description:
                  'Offrez des biens utiles : vêtements, nourriture, '
                      'fournitures scolaires et autres équipements.',
                  texteBouton: 'Faire un don',
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonMaterielGeneralPage(
                          donateurId: donateurId,
                          organisationPartenaireId:
                          organisationPartenaireId,
                          demandeAideId: demandeAideId,
                          prenom: prenom,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carteTypeDon({
    required BuildContext contexte,
    required IconData icone,
    required String titre,
    required String description,
    required String texteBouton,
    required VoidCallback action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône et titre
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CouleursApp.fond,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icone,
                  color: CouleursApp.vert,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 26),

          // Bouton
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.vert,
                foregroundColor: CouleursApp.blanc,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    texteBouton,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
