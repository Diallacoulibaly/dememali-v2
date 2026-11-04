
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../../models/organisation_partenaire.dart';
import 'widgets/a_propos_organisation_widget.dart';
import 'widgets/entete_organisation_widget.dart';
import 'widgets/liste_aides_distribuees_widget.dart';
import '/pages/donateur/don/faire_un_don_page.dart';

class DetailOrganisationPage extends ConsumerWidget {
  const DetailOrganisationPage({
    super.key,
    required this.organisation,
    required this.donateurId,
    required this.prenom,
  });

  final OrganisationPartenaire organisation;
  final int donateurId;
  final String prenom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),

      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // EN-TÊTE DE L'ORGANISATION
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: EnteteOrganisationWidget(
                organisation: organisation,
              ),
            ),

            const SizedBox(height: 16),

            // À PROPOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AProposOrganisationWidget(
                organisation: organisation,
              ),
            ),

            const SizedBox(height: 16),

            // BOUTON SOUTENIR L'ORGANISATION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaireUnDonPage(
                          donateurId: donateurId,
                          organisationPartenaireId: organisation.id,
                          prenom: prenom,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text(
                    'Soutenir cette organisation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7A4B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TITRE DES AIDES DISTRIBUÉES
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Aides distribuées',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F7A4B),
                ),
              ),
            ),

            const SizedBox(height: 12),
              ],
            )),
          ],
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListeAidesDistribueesWidget(
              organisationId: organisation.id,
            ),
          ),
        ),
      ),
    );
  }
}
