import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../styles/couleurs.dart';

/// Formatteur pour ajouter automatiquement des espaces entre les milliers (ex: 50 000)
class _SeparateurMilliersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Extraire uniquement les chiffres
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Supprimer les zéros non significatifs au début (ex: 05 -> 5, sauf si 0 seul)
    final nombre = int.tryParse(digits) ?? 0;
    final digitsNettoyes = nombre == 0 ? '0' : nombre.toString();

    // Compter combien de chiffres étaient avant le curseur dans newValue
    int nbChiffresAvantCurseur = 0;
    final selectionEnd = newValue.selection.end.clamp(0, newValue.text.length);
    for (int i = 0; i < selectionEnd; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        nbChiffresAvantCurseur++;
      }
    }

    // Formater avec séparateur de milliers
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final texteFormate =
        digitsNettoyes.replaceAllMapped(regex, (m) => '${m[1]} ');

    // Repositionner le curseur après le nombre correspondant de chiffres
    int nouvelOffset = 0;
    int chiffresComptes = 0;
    for (int i = 0; i < texteFormate.length; i++) {
      if (chiffresComptes >= nbChiffresAvantCurseur) {
        break;
      }
      if (RegExp(r'\d').hasMatch(texteFormate[i])) {
        chiffresComptes++;
      }
      nouvelOffset = i + 1;
    }

    return TextEditingValue(
      text: texteFormate,
      selection: TextSelection.collapsed(
        offset: nouvelOffset.clamp(0, texteFormate.length),
      ),
    );
  }
}

class Etape2Montant extends StatefulWidget {
  const Etape2Montant({
    super.key,
    required this.montantController,
    required this.onRetour,
    required this.onContinuer,
  });

  final TextEditingController montantController;
  final VoidCallback onRetour;
  final VoidCallback onContinuer;

  @override
  State<Etape2Montant> createState() => _Etape2MontantState();
}

class _Etape2MontantState extends State<Etape2Montant> {
  @override
  void initState() {
    super.initState();
    // Si une valeur numérique existe déjà, la formater proprement
    final texteInitial = widget.montantController.text.replaceAll(RegExp(r'\D'), '');
    if (texteInitial.isNotEmpty) {
      final nombre = int.tryParse(texteInitial) ?? 0;
      if (nombre > 0) {
        final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
        widget.montantController.text =
            nombre.toString().replaceAllMapped(regex, (m) => '${m[1]} ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carte principale blanche
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
              // MONTANT DE LA DEMANDE
              const Text(
                'MONTANT DE LA DEMANDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'INDIQUEZ LE MONTANT TOTAL NÉCESSAIRE POUR\nRÉPONDRE À VOTRE BESOIN.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.45),
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 18),

              // Cadre avec bordure verte et champ de saisie direct, cliquable et modifiable
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CouleursApp.vert, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: widget.montantController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  cursorColor: CouleursApp.vert,
                  enableInteractiveSelection: true,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: CouleursApp.noir,
                    letterSpacing: 0.5,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                    _SeparateurMilliersFormatter(),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withValues(alpha: 0.25),
                      letterSpacing: 0.5,
                    ),
                    suffixText: ' FCFA',
                    suffixStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: CouleursApp.noir,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Boutons Retour et Continuer
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: widget.onRetour,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CouleursApp.blanc,
                    foregroundColor: CouleursApp.noir,
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
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
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onContinuer,
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
            ),
          ],
        ),
      ],
    );
  }
}
