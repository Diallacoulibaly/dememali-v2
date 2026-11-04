
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/demande_aide.dart';
import '../../../../styles/couleurs.dart';
import '../../../../controllers/etude_terrain_controller.dart';

class HistoriqueDemandeWidget extends ConsumerWidget {
  final DemandeAide demande;

  const HistoriqueDemandeWidget({
    super.key,
    required this.demande,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync =
    ref.watch(etudeTerrainControllerProvider(demande.id));

    return _carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique de la demande',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Suivez les différentes étapes de traitement.',
            style: TextStyle(
              fontSize: 12,
              color: CouleursApp.noir.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 22),

          // Création de la demande
          _etape(
            icone: Icons.check_circle_outline,
            titre: 'Demande d’aide',
            description: 'Demande créée le ${_date(demande.dateCreation)}',
          ),

          // Étude de terrain
          etudeAsync.when(
            data: (etude) => _etape(
              icone: Icons.location_on_outlined,
              titre: 'Étude de terrain',
              description: etude == null
                  ? 'Aucune étude de terrain enregistrée.'
                  : 'Statut : ${etude.statut ?? 'Non précisé'}'
                  ' • ${_date(etude.dateRealisation ?? etude.datePlanification)}',
            ),
            loading: () => _etape(
              icone: Icons.location_on_outlined,
              titre: 'Étude de terrain',
              description: 'Chargement des informations...',
            ),
            error: (_, __) => _etape(
              icone: Icons.location_on_outlined,
              titre: 'Étude de terrain',
              description:
              'Les informations de l’étude ne sont pas disponibles.',
            ),
          ),

          // Rapport de besoin
          _etape(
            icone: Icons.description_outlined,
            titre: 'Rapport de besoin',
            description:
            'Besoin identifié et solution proposée.',
          ),

          // Rapport technique
          _etape(
            icone: Icons.assignment_outlined,
            titre: 'Rapport technique',
            description:
            'Articles, quantités, prix et montant final estimé.',
            dernier: true,
          ),
        ],
      ),
    );
  }

  // Élément de la timeline
  Widget _etape({
    required IconData icone,
    required String titre,
    required String description,
    bool dernier = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colonne de la timeline
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CouleursApp.vert.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CouleursApp.vert.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icone,
                    color: CouleursApp.vert,
                    size: 17,
                  ),
                ),

                if (!dernier)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: CouleursApp.vert.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Informations de l'étape
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                bottom: dernier ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.noir,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: CouleursApp.noir.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Carte principale
  Widget _carte({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  // Formatage de la date
  String _date(DateTime? date) {
    if (date == null) return 'Date non précisée';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
