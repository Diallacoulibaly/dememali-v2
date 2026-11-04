import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/categorie_demande.dart';
import '../../../../styles/couleurs.dart';

class Etape1Infos extends StatelessWidget {
  const Etape1Infos({
    super.key,
    required this.titreController,
    required this.descriptionController,
    required this.urgenceSelectionnee,
    required this.onUrgenceChange,
    required this.typeAideSelectionne,
    required this.onTypeAideChange,
    required this.nombrePersonneController,
    required this.onContinuer,
    this.categories = const [],
    this.categorieSelectionnee,
    this.onCategorieChange,
    this.chargementCategories = false,
  });

  final TextEditingController titreController;
  final TextEditingController descriptionController;
  final String urgenceSelectionnee;
  final ValueChanged<String> onUrgenceChange;
  final String typeAideSelectionne;
  final ValueChanged<String> onTypeAideChange;
  final TextEditingController nombrePersonneController;
  final VoidCallback onContinuer;
  final List<CategorieDemande> categories;
  final int? categorieSelectionnee;
  final ValueChanged<int?>? onCategorieChange;
  final bool chargementCategories;

  bool get _estIndividuelle =>
      typeAideSelectionne.toLowerCase().contains('individu');

  static const List<String> niveauxUrgence = [
    'Faible',
    'Moyenne',
    'Urgente',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carte principale blanche
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITRE DE LA DEMANDE
              const Text(
                'TITRE DE LA DEMANDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titreController,
                decoration: InputDecoration(
                  hintText: 'Aide alimentaire pour ma famille',
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: CouleursApp.blanc,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CouleursApp.vert, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CATÉGORIE DU BESOIN
              const Text(
                'CATÉGORIE DU BESOIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
                ),
                child: chargementCategories
                    ? const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CouleursApp.vert,
                            ),
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: (categories.any(
                                  (c) => c.id == categorieSelectionnee))
                              ? categorieSelectionnee
                              : (categories.isNotEmpty
                                  ? categories.first.id
                                  : null),
                          isExpanded: true,
                          hint: const Text(
                            'Sélectionnez une catégorie',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: CouleursApp.vert),
                          onChanged: onCategorieChange,
                          items: categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(
                                cat.nom,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: CouleursApp.noir,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // DESCRIPTION DU BESOIN
              const Text(
                'DESCRIPTION DU BESOIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Expliquez votre besoin...',
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.35),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: CouleursApp.blanc,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: CouleursApp.vert, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TYPE DE LA DEMANDE
              const Text(
                'TYPE DE LA DEMANDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CouleursApp.vert, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _estIndividuelle ? 'Individuelle' : 'Collective',
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: CouleursApp.vert,
                      size: 24,
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        onTypeAideChange(val);
                        if (val.toLowerCase().contains('individu')) {
                          nombrePersonneController.text = '1';
                        } else {
                          if ((int.tryParse(nombrePersonneController.text) ?? 1) <= 1) {
                            nombrePersonneController.text = '2';
                          }
                        }
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Individuelle',
                        child: Text(
                          'Individuelle',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.noir,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Collective',
                        child: Text(
                          'Collective',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: CouleursApp.noir,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // NOMBRE DE PERSONNE
              const Text(
                'NOMBRE DE PERSONNE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _estIndividuelle
                      ? const Color(0xFFF9F9F9)
                      : CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CouleursApp.vert,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: nombrePersonneController,
                    readOnly: _estIndividuelle,
                    enabled: !_estIndividuelle,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    cursorColor: CouleursApp.vert,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _estIndividuelle ? Colors.black54 : CouleursApp.noir,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              if (_estIndividuelle) ...[
                const SizedBox(height: 6),
                Text(
                  'Pour une demande individuelle, le nombre est fixé à 1.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.45),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // URGENCE
              const Text(
                'URGENCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: niveauxUrgence.map((urgence) {
                  final estSelectionne = urgenceSelectionnee.toLowerCase() == urgence.toLowerCase();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => onUrgenceChange(urgence),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: estSelectionne ? CouleursApp.vert : CouleursApp.blanc,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: estSelectionne
                                  ? CouleursApp.vert
                                  : Colors.black.withValues(alpha: 0.15),
                              width: estSelectionne ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            urgence,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: estSelectionne ? CouleursApp.blanc : CouleursApp.noir,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Bouton Continuer
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onContinuer,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.vert,
              foregroundColor: CouleursApp.blanc,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
