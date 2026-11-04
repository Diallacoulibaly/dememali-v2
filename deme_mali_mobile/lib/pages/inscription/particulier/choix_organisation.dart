
import 'package:flutter/material.dart';

import '../../../models/organisation_partenaire.dart';
import '../../../repositories/organisation_repository.dart';
import '../../../styles/couleurs.dart';
import '../widgets/bouton_continuer.dart';
import '../structure/informations_structure_etape1.dart';
import 'informations_personnelles_particulier.dart';

class ChoixOrganisationPage extends StatefulWidget {
  final String typeCompte;

  const ChoixOrganisationPage({
    super.key,
    this.typeCompte = 'PARTICULIER',
  });

  @override
  State<ChoixOrganisationPage> createState() => _ChoixOrganisationPageState();
}

class _ChoixOrganisationPageState extends State<ChoixOrganisationPage> {
  final OrganisationRepository repository = OrganisationRepository();
  final TextEditingController rechercheController = TextEditingController();

  // Filtres affichés sous la recherche : libellé -> type du backend
  static const Map<String, String?> filtres = {
    'Toutes': null,
    'ONG': 'ONG',
    'Association': 'ASSOCIATION',
    'Fondation': 'FONDATION',
  };

  List<OrganisationPartenaire> organisations = [];
  OrganisationPartenaire? selection;
  String recherche = '';
  String filtreActif = 'Toutes';
  bool chargement = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  Future<void> _charger({bool forcer = false}) async {
    setState(() {
      chargement = organisations.isEmpty;
      erreur = null;
    });

    try {
      final resultat = await repository.recupererValidees(forcer: forcer);
      if (!mounted) return;
      setState(() => organisations = resultat);
    } catch (e) {
      debugPrint('ERREUR CHARGEMENT ORGANISATIONS : $e');
      if (!mounted) return;
      setState(() {
        erreur = 'Impossible de charger les organisations. '
            'Vérifiez votre connexion.';
      });
    } finally {
      if (mounted) setState(() => chargement = false);
    }
  }

  List<OrganisationPartenaire> get organisationsFiltrees {
    final terme = recherche.trim().toLowerCase();
    final type = filtres[filtreActif];

    return organisations.where((o) {
      final correspondType = type == null || o.type == type;
      final correspondNom = terme.isEmpty || o.nomOrganisation.toLowerCase().contains(terme);
      return correspondType && correspondNom;
    }).toList();
  }

  void _continuer() {
    final organisation = selection;
    if (organisation == null) return;

    if (widget.typeCompte == 'STRUCTURE') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InformationsStructureEtape1Page(
            organisationId: organisation.id,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsPersonnellesParticulierPage(
          organisationId: organisation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: CouleursApp.vert,
                onRefresh: () => _charger(forcer: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BOUTON RETOUR
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: CouleursApp.noir,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    const Text(
                      'Choisissez votre organisation partenaire',
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.noir,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sélectionnez l’organisation qui vous accompagne '
                          'pour poursuivre votre inscription.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // RECHERCHE
                    TextField(
                      controller: rechercheController,
                      onChanged: (v) => setState(() => recherche = v),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une organisation...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 22,
                          color: Color(0xFF555555),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        border: _bordureRecherche(),
                        enabledBorder: _bordureRecherche(),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: CouleursApp.vert),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'ORGANISATIONS DISPONIBLES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // FILTRES
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filtres.keys.map(_pastilleFiltre).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _contenuListe(),
                  ],
                ),
                ),
              ),
            ),

            // BOUTON FIXE EN BAS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: BoutonContinuer(
                actif: selection != null,
                onPressed: _continuer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _bordureRecherche() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEDE6D8)),
    );
  }

  Widget _contenuListe() {
    if (chargement) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: CouleursApp.vert),
        ),
      );
    }

    if (erreur != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: Column(
            children: [
              Text(
                erreur!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _charger(forcer: true),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(color: CouleursApp.vert),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final liste = organisationsFiltrees;

    if (liste.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: Text(
            'Aucune organisation trouvée.',
            style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
          ),
        ),
      );
    }

    return Column(children: liste.map(_carteOrganisation).toList());
  }

  Widget _pastilleFiltre(String libelle) {
    final actif = filtreActif == libelle;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => filtreActif = libelle),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: actif ? 18 : 24,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: actif ? CouleursApp.vert : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: actif ? CouleursApp.vert : const Color(0xFFE2DACB),
            ),
          ),
          child: Text(
            libelle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: actif ? FontWeight.bold : FontWeight.w500,
              color: actif ? Colors.white : const Color(0xFF444444),
            ),
          ),
        ),
      ),
    );
  }

  Widget _carteOrganisation(OrganisationPartenaire organisation) {
    final choisie = selection?.id == organisation.id;
    final estFondation = organisation.type == 'FONDATION';

    final sousTitre = [
      organisation.typeLibelle,
      if (organisation.ville.trim().isNotEmpty)
        organisation.ville.trim(),
    ].where((e) => e.isNotEmpty).join(' · ');

    final description = (organisation.description ?? '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => selection = organisation),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: choisie ? CouleursApp.vert : const Color(0xFFE9E2D3),
              width: choisie ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: estFondation
                      ? const Color(0xFFFFF0C9)
                      : const Color(0xFFE4F1E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 34,
                  color: Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(width: 12),

              // TEXTES
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organisation.nomOrganisation,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.noir,
                      ),
                    ),
                    if (sousTitre.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        sousTitre,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                    if (choisie) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Sélectionnée',
                        style: TextStyle(
                          fontSize: 10,
                          color: CouleursApp.vert,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // CERCLE DE SELECTION
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: choisie ? CouleursApp.vert : Colors.white,
                  border: Border.all(
                    color: choisie
                        ? CouleursApp.vert
                        : const Color(0xFFDADADA),
                  ),
                ),
                child: choisie
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
