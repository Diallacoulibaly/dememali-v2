
import 'package:flutter/material.dart';

import '../widgets/barre_navigation.dart';
import 'donateur/accueil_donateur.dart';
import 'donateur/organisation/organisation_page.dart';
import 'donateur/mes_dons/mes_dons_page.dart';
import 'donateur/profil/profil_donateur_page.dart';

class NavigationDonateurPage extends StatefulWidget {
  final String prenom;
  final int donateurId;

  const NavigationDonateurPage({
    super.key,
    required this.prenom,
    required this.donateurId,
  });

  @override
  State<NavigationDonateurPage> createState() =>
      _NavigationDonateurPageState();
}

class _NavigationDonateurPageState
    extends State<NavigationDonateurPage> {
  int indexSelectionne = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      body: IndexedStack(
        index: indexSelectionne,
        children: [
          AccueilDonateurPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
          ),

          OrganisationPage(
            donateurId: widget.donateurId,
            prenom: widget.prenom,
          ),

          MesDonsPage(
            donateurId: widget.donateurId,
          ),

          ProfilDonateurPage(
            donateurId: widget.donateurId,
            nomDonateur: widget.prenom,
          ),
        ],
      ),
      bottomNavigationBar: BarreNavigation(
        indexSelectionne: indexSelectionne,
        onTap: (index) {
          setState(() {
            indexSelectionne = index;
          });
        },
      ),
    );
  }
}
