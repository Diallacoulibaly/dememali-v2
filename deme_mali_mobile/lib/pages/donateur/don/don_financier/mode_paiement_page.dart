
import 'package:flutter/material.dart';

import '/styles/couleurs.dart';
import 'informations_paiement_page.dart';

class ModePaiementPage extends StatefulWidget {
  final double montant;
  final bool anonyme;
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;
  final String prenom;

  const ModePaiementPage({
    super.key,
    required this.montant,
    required this.anonyme,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  State<ModePaiementPage> createState() => _ModePaiementPageState();
}

class _ModePaiementPageState extends State<ModePaiementPage> {
  // Orange Money est sélectionné par défaut.
  String _modePaiement = 'ORANGE_MONEY';

  final List<Map<String, dynamic>> _modes = [
    {
      'nom': 'Orange Money',
      'valeur': 'ORANGE_MONEY',
      'image': 'assets/images/orange_money.png',
      'couleur': Colors.deepOrange,
    },
    {
      'nom': 'Wave',
      'valeur': 'WAVE',
      'image': 'assets/images/wave.png',
      'couleur': Colors.lightBlue,
    },
    {
      'nom': 'Moov Money',
      'valeur': 'MOVE_MONEY',
      'image': 'assets/images/moov_money.png',
      'couleur': Colors.orange,
    },
  ];

  String get _montantFormate {
    return widget.montant.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    );
  }

  void _continuer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationsPaiementPage(
          montant: widget.montant,
          anonyme: widget.anonyme,
          modePaiement: _modePaiement,
          donateurId: widget.donateurId,
          demandeAideId: widget.demandeAideId,
          organisationPartenaireId:
          widget.organisationPartenaireId,
          prenom: widget.prenom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
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
                      'Paiement',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Choisissez votre mode de paiement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CouleursApp.noir,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // Informations générales du don
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CouleursApp.vert.withValues(alpha: 0.20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Récapitulatif du don',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Montant',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),

                    Text(
                      '$_montantFormate FCFA',
                      style: const TextStyle(
                        color: CouleursApp.vert,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Moyen de paiement',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Liste des moyens de paiement
              Expanded(
                child: ListView.separated(
                  itemCount: _modes.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mode = _modes[index];
                    final selectionne =
                        _modePaiement == mode['valeur'];
                    final couleur = mode['couleur'] as Color;

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        setState(() {
                          _modePaiement = mode['valeur'] as String;
                        });
                      },
                      child: Container(
                        height: 76,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: CouleursApp.blanc,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selectionne
                                ? CouleursApp.vert
                                : const Color(0xFFE3DDD2),
                            width: selectionne ? 1.7 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo du moyen de paiement
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: couleur.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                mode['image'] as String,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported_outlined,
                                    color: couleur,
                                    size: 24,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Text(
                                mode['nom'] as String,
                                style: const TextStyle(
                                  color: CouleursApp.noir,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Icon(
                              selectionne
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selectionne
                                  ? CouleursApp.vert
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bouton Continuer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continuer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
