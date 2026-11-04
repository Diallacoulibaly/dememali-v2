
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/organisation_partenaire.dart';
import '../../../models/like_organisation.dart';
import '../../../repositories/organisation_partenaire_repository.dart';
import '../../../repositories/like_organisation_repository.dart';
import '../../../styles/couleurs.dart';
import 'widgets/barre_recherche_organisation.dart';
import 'widgets/liste_organisations.dart';
import 'detail_organisation/detail_organisation_page.dart';
import '../don/faire_un_don_page.dart';

class OrganisationPage extends ConsumerStatefulWidget {
  final int donateurId;
  final String prenom;

  const OrganisationPage({
    super.key,
    required this.donateurId,
    required this.prenom,
  });

  @override
  ConsumerState<OrganisationPage> createState() =>
      _OrganisationPageState();
}

class _OrganisationPageState extends ConsumerState<OrganisationPage> {
  String recherche = '';
  final Set<int> organisationsAimees = {};

  @override
  void initState() {
    super.initState();
    _chargerOrganisationsAimees();
  }

  Future<void> _chargerOrganisationsAimees() async {
    try {
      final organisations = await ref.read(
        organisationsAimeesProvider(widget.donateurId).future,
      );

      if (!mounted) return;

      setState(() {
        organisationsAimees
          ..clear()
          ..addAll(organisations.map((organisation) => organisation.id));
      });
    } catch (_) {
      // La liste principale reste disponible si les favoris ne se chargent pas.
    }
  }

  Future<void> _actualiser() async {
    final liste = organisationsAvecLikesProvider(widget.donateurId);
    ref.invalidate(organisationsAimeesProvider(widget.donateurId));

    final chargementListe = ref.refresh(liste.future);
    await _chargerOrganisationsAimees();
    try {
      await chargementListe;
    } catch (_) {
      // L'état d'erreur du provider affiche déjà le bouton Réessayer.
    }
  }

  Future<void> _changerLike(
      OrganisationPartenaire organisation,
      ) async {
    final idOrganisation = organisation.id;
    final dejaAimee = organisationsAimees.contains(idOrganisation);

    final like = LikeOrganisation(
      donateurId: widget.donateurId,
      organisationId: idOrganisation,
    );

    try {
      final repository = ref.read(likeOrganisationRepositoryProvider);

      if (dejaAimee) {
        await repository.retirerLike(like);
      } else {
        await repository.aimerOrganisation(like);
      }

      if (!mounted) return;

      setState(() {
        if (dejaAimee) {
          organisationsAimees.remove(idOrganisation);
        } else {
          organisationsAimees.add(idOrganisation);
        }
      });

      ref.invalidate(organisationsAimeesProvider(widget.donateurId));
      ref.invalidate(organisationsAvecLikesProvider(widget.donateurId));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de modifier le favori. Réessaie.'),
        ),
      );
    }
  }

  List<OrganisationPartenaire> _rechercherOrganisations(
      List<OrganisationPartenaire> organisations,
      ) {
    final terme = recherche.trim().toLowerCase();

    if (terme.isEmpty) return organisations;

    return organisations.where((organisation) {
      return organisation.nomOrganisation.toLowerCase().contains(terme) ||
          organisation.ville.toLowerCase().contains(terme) ||
          organisation.typeOrganisation.toLowerCase().contains(terme);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final organisationsAsync = ref.watch(
      organisationsAvecLikesProvider(widget.donateurId),
    );

    return Scaffold(
      backgroundColor: CouleursApp.fond,

      appBar: AppBar(
        backgroundColor: CouleursApp.fond,
        foregroundColor: CouleursApp.noir,
        elevation: 0,
        title: const Text(
          'Organisations partenaires',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: organisationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: CouleursApp.vert,
            ),
          ),

          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_outlined,
                    size: 44,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Impossible de charger les organisations.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(
                      organisationsAvecLikesProvider(widget.donateurId),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.vert,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          data: (organisations) {
            final organisationsFiltrees =
            _rechercherOrganisations(organisations);

            return RefreshIndicator(
              color: CouleursApp.vert,
              onRefresh: _actualiser,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  const SizedBox(height: 8),

                  const Text(
                    'Découvrez la liste des organisations partenaires.',
                    style: TextStyle(
                      fontSize: 14,
                      color: CouleursApp.noir,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  BarreRechercheOrganisation(
                    onRechercheChangee: (valeur) {
                      setState(() => recherche = valeur);
                    },
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nos organisations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.noir,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ListeOrganisations(
                    organisations: organisationsFiltrees,

                    estAimee: (organisation) =>
                        organisationsAimees.contains(organisation.id),

                    onLike: _changerLike,

                    onVoirOrganisation: (organisation) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailOrganisationPage(
                            organisation: organisation,
                            donateurId: widget.donateurId,
                            prenom: widget.prenom,
                          ),
                        ),
                      );
                    },

                    onSoutenir: (organisation) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaireUnDonPage(
                            donateurId: widget.donateurId,
                            organisationPartenaireId: organisation.id,
                            prenom: widget.prenom,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
