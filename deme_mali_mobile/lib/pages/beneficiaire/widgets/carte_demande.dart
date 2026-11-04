import 'package:flutter/material.dart';
import '../../../models/demande_aide.dart';
import '../../../styles/couleurs.dart';

class CarteDemande extends StatelessWidget {
  const CarteDemande({
    super.key,
    required this.demande,
    this.onTap,
  });

  final DemandeAide demande;
  final VoidCallback? onTap;

  String get statutLisible {
    switch (demande.statut.toUpperCase()) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'VALIDEE':
      case 'VALIDÉE':
      case 'ACCEPTEE':
      case 'ACCEPTÉE':
        return 'Validée';
      case 'REJETEE':
      case 'REJETÉE':
        return 'Rejetée';
      case 'EN_COURS':
      case 'EN_COURS_DE_TRAITEMENT':
        return 'En cours';
      default:
        return demande.statut.isEmpty
            ? 'Statut indisponible'
            : demande.statut;
    }
  }

  Color get couleurStatut {
    final s = demande.statut.toUpperCase();

    if ([
      'VALIDEE',
      'VALIDÉE',
      'ACCEPTEE',
      'ACCEPTÉE',
    ].contains(s)) {
      return CouleursApp.vert;
    }

    if (s == 'REJETEE' || s == 'REJETÉE') {
      return Colors.red.shade700;
    }

    return Colors.brown.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final d = demande.dateCreation;
    final date = d == null
        ? 'Date non disponible'
        : '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';

    return Material(
      color: CouleursApp.blanc,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      demande.titre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: couleurStatut.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statutLisible,
                      style: TextStyle(
                        color: couleurStatut,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                demande.categorieDemandeNom ??
                    demande.typeDemandeAide ??
                    'Catégorie non précisée',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: CouleursApp.vert,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
