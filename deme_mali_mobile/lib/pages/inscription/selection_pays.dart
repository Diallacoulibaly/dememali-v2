
import 'package:flutter/material.dart';

import '../../models/pays.dart';
import '../../repositories/pays_repository.dart';
import '../../styles/couleurs.dart';
import 'informations_personnelles.dart';
import 'widgets/bouton_continuer.dart';
import 'widgets/drapeau_pays.dart';
import 'widgets/entete_inscription.dart';

class SelectionPaysPage extends StatefulWidget {
  // Type de compte choisi à l'écran précédent (ex : DONATEUR)
  final String typeCompte;

  const SelectionPaysPage({super.key, required this.typeCompte});

  @override
  State<SelectionPaysPage> createState() => _SelectionPaysPageState();
}

class _SelectionPaysPageState extends State<SelectionPaysPage> {
  final TextEditingController rechercheController = TextEditingController();
  final PaysRepository paysRepository = PaysRepository();

  Pays? paysSelectionne;
  String recherche = '';
  bool verification = false;

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  List<Pays> get paysFiltres {
    final terme = recherche.trim().toLowerCase();
    if (terme.isEmpty) return Pays.liste;

    return Pays.liste
        .where(
          (p) =>
      p.nom.toLowerCase().contains(terme) ||
          p.code.toLowerCase().contains(terme),
    )
        .toList();
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _continuer() async {
    final pays = paysSelectionne;
    if (pays == null || verification) return;

    setState(() => verification = true);

    int? paysId;
    try {
      final ids = await paysRepository.recupererIdsParNom();
      paysId = ids[pays.nom.toLowerCase()];
    } catch (_) {
      if (!mounted) return;
      setState(() => verification = false);
      _afficherMessage(
        'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => verification = false);

    if (paysId == null) {
      _afficherMessage(
        "Les inscriptions ne sont pas encore ouvertes pour ce pays.",
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsPersonnellesPage(
          typeCompte: widget.typeCompte,
          pays: pays,
          paysId: paysId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultats = paysFiltres;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EnteteInscription(titre: 'Sélectionnez votre pays'),
                    const SizedBox(height: 28),

                    // RECHERCHE
                    TextField(
                      controller: rechercheController,
                      onChanged: (v) => setState(() => recherche = v),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Rechercher',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Color(0xFF555555),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: CouleursApp.vert,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // LISTE DES PAYS
                    if (resultats.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Center(
                          child: Text(
                            'Aucun pays trouvé.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ),
                      )
                    else
                      ...resultats.map(_carte),
                  ],
                ),
              ),
            ),

            // BOUTON FIXE EN BAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFECE8DF))),
              ),
              child: BoutonContinuer(
                actif: paysSelectionne != null && !verification,
                onPressed: _continuer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carte(Pays pays) {
    final selectionne = paysSelectionne?.code == pays.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => paysSelectionne = pays),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectionne ? CouleursApp.vert : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              DrapeauPays(code: pays.code),
              const SizedBox(width: 12),
              SizedBox(
                width: 26,
                child: Text(
                  pays.code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pays.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
              // CERCLE DE SELECTION
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: selectionne
                        ? CouleursApp.vert
                        : const Color(0xFFDADADA),
                    width: selectionne ? 2 : 1,
                  ),
                ),
                child: selectionne
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: CouleursApp.vert,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
