import 'package:flutter/material.dart';
import '../../../../models/justificatif.dart';
import '../../../../styles/couleurs.dart';

class Etape3Justificatifs extends StatelessWidget {
  const Etape3Justificatifs({
    super.key,
    required this.typeJustificatif,
    required this.fichiers,
    required this.chargement,
    required this.onTypeJustificatifChange,
    required this.onAjouterFichier,
    required this.onSupprimerFichier,
    required this.onRetour,
    required this.onEnvoyer,
    this.typesDisponibles = const [
      'Certificat médical',
      'Pièce d’identité',
      'Certificat de scolarité',
      'Facture d’électricité / eau',
      'Autre justificatif',
    ],
  });

  final String typeJustificatif;
  final List<Justificatif> fichiers;
  final bool chargement;
  final ValueChanged<String> onTypeJustificatifChange;
  final VoidCallback onAjouterFichier;
  final ValueChanged<int> onSupprimerFichier;
  final VoidCallback onRetour;
  final VoidCallback onEnvoyer;
  final List<String> typesDisponibles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre & Sous-titre de l'étape 3
        const Text(
          'Justifiez votre demande',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: CouleursApp.noir,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ajoutez les documents nécessaires pour nous aider à vérifier votre situation.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black.withValues(alpha: 0.6),
            height: 1.35,
          ),
        ),

        const SizedBox(height: 20),

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
              // TYPE DE JUSTIFICATIF
              const Text(
                'TYPE DE JUSTIFICATIF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Dropdown vert
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CouleursApp.vert, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: typesDisponibles.contains(typeJustificatif)
                        ? typeJustificatif
                        : typesDisponibles.first,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: CouleursApp.vert),
                    onChanged: (val) {
                      if (val != null) onTypeJustificatifChange(val);
                    },
                    items: typesDisponibles.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined, color: CouleursApp.vert, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CouleursApp.noir,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Zone d'upload avec bordure en pointillés verts
              CustomPaint(
                painter: _DottedBorderPainter(
                  color: CouleursApp.vert,
                  radius: 16,
                  dashWidth: 6,
                  dashSpace: 4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Icône document avec badge plus vert
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: CouleursApp.blanc,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: CouleursApp.vert,
                              size: 26,
                            ),
                          ),
                          Positioned(
                            right: -4,
                            top: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: CouleursApp.vert,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: CouleursApp.blanc, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ajouter un justificatif',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CouleursApp.noir,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, JPG ou PNG',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: onAjouterFichier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CouleursApp.vert,
                          foregroundColor: CouleursApp.blanc,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Choisir un fichier',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Liste des fichiers uploadés
              for (int i = 0; i < fichiers.length; i++) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF9F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      // Badge PDF vert
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: CouleursApp.vert,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fichiers[i].extension.toUpperCase(),
                          style: const TextStyle(
                            color: CouleursApp.blanc,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fichiers[i].nom,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: CouleursApp.noir,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${fichiers[i].taille} • Terminé',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => onSupprimerFichier(i),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.black.withValues(alpha: 0.5),
                        iconSize: 22,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],

              // Bouton "+ Ajouter un autre justificatif"
              Center(
                child: TextButton.icon(
                  onPressed: onAjouterFichier,
                  icon: const Icon(Icons.add, color: CouleursApp.vert, size: 18),
                  label: const Text(
                    'Ajouter un autre justificatif',
                    style: TextStyle(
                      color: CouleursApp.vert,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Boutons Retour et Envoyer ma demande
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: chargement ? null : onRetour,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CouleursApp.blanc,
                    foregroundColor: CouleursApp.noir,
                    side: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Retour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: chargement ? null : onEnvoyer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: chargement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: CouleursApp.blanc,
                          ),
                        )
                      : const Text(
                          'Envoyer ma demande',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Peintre personnalisé pour la bordure en pointillés
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = dashWidth;
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
