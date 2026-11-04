
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controllers/etude_terrain_controller.dart';
import '../../../../models/demande_aide.dart';
import '../../../../styles/couleurs.dart';

class EtudeTerrainWidget extends ConsumerWidget {
  final DemandeAide demande;

  const EtudeTerrainWidget({
    super.key,
    required this.demande,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync =
    ref.watch(etudeTerrainControllerProvider(demande.id));

    return etudeAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: CouleursApp.vert,
          ),
        ),
      ),
      error: (erreur, _) => _message(
        'Impossible de charger les informations de l’étude de terrain.',
      ),
      data: (etude) {
        if (etude == null) {
          return _message(
            'Aucune étude de terrain n’est encore associée à cette demande.',
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CouleursApp.vert.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Étude de terrain',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  _statut(etude.statut),
                ],
              ),

              const SizedBox(height: 20),

              // Objectif
              _information(
                titre: 'Objectif de l’étude',
                valeur: etude.objectif,
              ),

              const SizedBox(height: 18),
              _separateur(),

              // Localisation et dates
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _information(
                      titre: 'Lieu',
                      valeur: etude.lieu,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _information(
                      titre: 'Heure',
                      valeur: etude.heure,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _information(
                      titre: 'Date planifiée',
                      valeur: _date(etude.datePlanification),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _information(
                      titre: 'Date de réalisation',
                      valeur: _date(etude.dateRealisation),
                    ),
                  ),
                ],
              ),

              // Observations
              if (etude.observation != null &&
                  etude.observation!.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                _separateur(),
                const SizedBox(height: 16),
                _information(
                  titre: 'Observations',
                  valeur: etude.observation,
                ),
              ],

              // Résultat
              if (etude.resultat != null &&
                  etude.resultat!.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CouleursApp.fond,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _information(
                    titre: 'Résultat de l’étude',
                    valeur: etude.resultat,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Affichage des informations
  Widget _information({
    required String titre,
    required String? valeur,
  }) {
    if (valeur == null || valeur.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CouleursApp.noir.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          valeur.trim(),
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: CouleursApp.noir,
          ),
        ),
      ],
    );
  }

  // Séparateur discret
  Widget _separateur() {
    return Container(
      height: 1,
      color: CouleursApp.noir.withValues(alpha: 0.08),
    );
  }

  // Statut de l'étude
  Widget _statut(String? statut) {
    if (statut == null || statut.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: CouleursApp.vert.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut.replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CouleursApp.vert,
        ),
      ),
    );
  }

  // Message en cas d'absence de données ou d'erreur
  Widget _message(String texte) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: CouleursApp.noir.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  // Format de date
  String? _date(DateTime? date) {
    if (date == null) return null;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
