
import 'package:flutter/material.dart';

class EnteteListeDemandes extends StatefulWidget {
  final ValueChanged<String> onRechercheChanged;

  final List<String> categories;
  final String categorieSelectionnee;
  final ValueChanged<String> onCategorieChanged;

  final int nombreDemandes;
  final VoidCallback? onRetour;
  final VoidCallback? onNotifications;

  const EnteteListeDemandes({
    super.key,
    required this.onRechercheChanged,
    required this.categories,
    required this.categorieSelectionnee,
    required this.onCategorieChanged,
    required this.nombreDemandes,
    this.onRetour,
    this.onNotifications,
  });

  @override
  State<EnteteListeDemandes> createState() =>
      _EnteteListeDemandesState();
}

class _EnteteListeDemandesState
    extends State<EnteteListeDemandes> {

  final TextEditingController _rechercheController =
  TextEditingController();

  static const Color vert = Color(0xFF0F7A4B);
  static const Color beige = Color(0xFFF7F3EA);
  static const Color fonce = Color(0xFF1F1F1F);
  static const Color gris = Color(0xFF777777);

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  // FILTRES HORIZONTAUX
  Widget _construireFiltres({
    required List<String> valeurs,
    required String selection,
    required ValueChanged<String> onSelection,
  }) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: valeurs.length,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final valeur = valeurs[index];
          final actif = valeur == selection;

          return Material(
            color: actif ? vert : Colors.white,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelection(valeur),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: actif
                        ? vert
                        : const Color(0xFFEAE6DF),
                  ),
                ),
                child: Text(
                  valeur,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: actif ? Colors.white : fonce,
                    fontSize: 11,
                    fontWeight: actif
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // BOUTONS RONDS
  Widget _construireBoutonRond({
    required IconData icone,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icone,
            size: 21,
            color: fonce,
          ),
        ),
      ),
    );
  }

  // BARRE DE RECHERCHE
  Widget _construireRecherche() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAE6DF),
        ),
      ),
      child: TextField(
        controller: _rechercheController,
        textInputAction: TextInputAction.search,
        onChanged: (valeur) {
          widget.onRechercheChanged(valeur);

          // Actualise l'affichage de l'icône d'effacement.
          setState(() {});
        },
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Rechercher une demande...',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: gris,
          ),
          suffixIcon: _rechercheController.text.isNotEmpty
              ? IconButton(
            onPressed: () {
              _rechercheController.clear();
              widget.onRechercheChanged('');
              setState(() {});
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: beige,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          // EN-TÊTE
          Row(
            children: [
              _construireBoutonRond(
                icone: Icons.arrow_back_rounded,
                onTap: widget.onRetour ??
                        () => Navigator.of(context).maybePop(),
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    "Demandes d'aide",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: fonce,
                    ),
                  ),
                ),
              ),

              _construireBoutonRond(
                icone: Icons.notifications_none_rounded,
                onTap: widget.onNotifications,
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Découvrez les personnes et familles qui ont besoin de votre soutien.',
            style: TextStyle(
              color: gris,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // RECHERCHE
          _construireRecherche(),

          const SizedBox(height: 14),

          const Text(
            'Catégorie',
            style: TextStyle(
              color: fonce,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          _construireFiltres(
            valeurs: widget.categories,
            selection: widget.categorieSelectionnee,
            onSelection: widget.onCategorieChanged,
          ),

          const SizedBox(height: 12),

          // NOMBRE DE RÉSULTATS
          Text(
            '${widget.nombreDemandes} demande${widget.nombreDemandes > 1 ? 's' : ''} trouvée${widget.nombreDemandes > 1 ? 's' : ''}',
            style: const TextStyle(
              color: fonce,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
