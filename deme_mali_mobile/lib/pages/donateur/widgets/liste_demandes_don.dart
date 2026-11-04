
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/demande_aide_controller.dart';
import '../../../styles/couleurs.dart';
import 'carte_demande_don.dart';
import '../detail/detail_demande_page.dart';
import '../don/faire_un_don_page.dart';
import '../don/don_financier/don_financier_page.dart';

class ListeDemandesDon extends ConsumerWidget {
  final int? categorieSelectionneeId;
  final int donateurId;
  final int? organisationPartenaireId;
  final String prenom;

  const ListeDemandesDon({
    super.key,
    this.categorieSelectionneeId,
    required this.donateurId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandesAsync = ref.watch(demandeAideControllerProvider);

    return demandesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: CouleursApp.vert,
        ),
      ),

      error: (error, stackTrace) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 35),
          const Icon(
            Icons.wifi_off_outlined,
            color: CouleursApp.vert,
            size: 45,
          ),
          const SizedBox(height: 12),
          const Text(
            'Impossible de charger les demandes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CouleursApp.noir,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ref.invalidate(demandeAideControllerProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.vert,
                foregroundColor: CouleursApp.blanc,
              ),
              child: const Text('Réessayer'),
            ),
          ),
        ],
      ),

      data: (demandes) {
        final demandesFiltrees = categorieSelectionneeId == null
            ? demandes
            : demandes
            .where(
              (demande) =>
          demande.categorieDemandeId ==
              categorieSelectionneeId,
        )
            .toList();

        if (demandesFiltrees.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 35),
              Icon(
                Icons.volunteer_activism_outlined,
                color: CouleursApp.vert,
                size: 50,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune demande dans cette catégorie.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CouleursApp.noir,
                  fontSize: 15,
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          itemCount: demandesFiltrees.length,
          itemBuilder: (context, index) {
            final demande = demandesFiltrees[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CarteDemandeDon(
                demande: demande,
                onFaireDon: () {
                  _ouvrirChoixDon(context, demande);
                },
                onVoirDetail: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailDemandePage(
                        demande: demande,
                        donateurId: donateurId,
                        organisationPartenaireId:
                        organisationPartenaireId,
                        prenom: prenom,
                        onFaireDon: () {
                          Navigator.pop(context);
                          _ouvrirChoixDon(context, demande);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _ouvrirChoixDon(BuildContext context, dynamic demande) {
    if (demande.estFinanciere) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonFinancierPage(
            donateurId: donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId: organisationPartenaireId,
            prenom: prenom,
          ),
        ),
      );
    } else if (demande.estMaterielle) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaireUnDonPage(
            donateurId: donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId: organisationPartenaireId,
            prenom: prenom,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le type de cette demande est inconnu.'),
        ),
      );
    }
  }
}
