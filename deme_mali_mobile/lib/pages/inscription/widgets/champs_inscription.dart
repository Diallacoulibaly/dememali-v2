
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../styles/couleurs.dart';

OutlineInputBorder _bordure() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFEDE6D8)),
  );
}

InputDecoration _decoration(String indication, Widget? suffixe) {
  return InputDecoration(
    hintText: indication,
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: _bordure(),
    enabledBorder: _bordure(),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: CouleursApp.vert),
    ),
    suffixIcon: suffixe,
  );
}

Widget _etiquette(String titre) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      titre,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: CouleursApp.noir,
      ),
    ),
  );
}

// Champ de saisie avec icône optionnelle à droite
class ChampInscription extends StatefulWidget {
  final String titre;
  final String indication;
  final TextEditingController controller;
  final IconData? icone;
  final bool motDePasse;
  final TextInputType typeClavier;
  final ValueChanged<String>? onChanged;
  final int lignes;
  final List<TextInputFormatter>? formatteurs;

  const ChampInscription({
    super.key,
    required this.titre,
    required this.indication,
    required this.controller,
    this.icone,
    this.motDePasse = false,
    this.typeClavier = TextInputType.text,
    this.onChanged,
    this.lignes = 1,
    this.formatteurs,
  });

  @override
  State<ChampInscription> createState() => _ChampInscriptionState();
}

class _ChampInscriptionState extends State<ChampInscription> {
  bool _masque = true;

  @override
  Widget build(BuildContext context) {
    Widget? suffixe;

    if (widget.motDePasse) {
      suffixe = IconButton(
        onPressed: () => setState(() => _masque = !_masque),
        icon: Icon(
          _masque ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: const Color(0xFF555555),
        ),
      );
    } else if (widget.icone != null) {
      suffixe = Icon(widget.icone, size: 20, color: const Color(0xFF555555));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquette(widget.titre),
        TextField(
          controller: widget.controller,
          keyboardType: widget.typeClavier,
          obscureText: widget.motDePasse && _masque,
          onChanged: widget.onChanged,
          minLines: widget.lignes,
          maxLines: widget.motDePasse ? 1 : widget.lignes,
          inputFormatters: widget.formatteurs,
          style: const TextStyle(fontSize: 13),
          decoration: _decoration(widget.indication, suffixe),
        ),
      ],
    );
  }
}

// Liste déroulante (genre, ville...)
class ChampListeInscription extends StatelessWidget {
  final String titre;
  final String indication;
  final List<String> options;
  final String? valeur;
  final IconData? icone;
  final ValueChanged<String?> onChanged;

  const ChampListeInscription({
    super.key,
    required this.titre,
    required this.indication,
    required this.options,
    required this.valeur,
    required this.onChanged,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquette(titre),
        DropdownButtonFormField<String>(
          initialValue: valeur,
          isExpanded: true,
          icon: Icon(
            icone ?? Icons.keyboard_arrow_down,
            size: 20,
            color: const Color(0xFF555555),
          ),
          decoration: _decoration(indication, null),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(fontSize: 13, color: CouleursApp.noir),
          items: options
              .map(
                (o) => DropdownMenuItem<String>(
              value: o,
              child: Text(o),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Champ date : ouvre un calendrier et affiche JJ / MM / AAAA
class ChampDateInscription extends StatelessWidget {
  final String titre;
  final DateTime? valeur;
  final ValueChanged<DateTime> onChoisie;

  const ChampDateInscription({
    super.key,
    required this.titre,
    required this.valeur,
    required this.onChoisie,
  });

  String _formater(DateTime d) {
    final jour = d.day.toString().padLeft(2, '0');
    final mois = d.month.toString().padLeft(2, '0');
    return '$jour / $mois / ${d.year}';
  }

  Future<void> _choisir(BuildContext context) async {
    final choix = await showDatePicker(
      context: context,
      initialDate: valeur ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CouleursApp.vert,
              onPrimary: Colors.white,
              onSurface: CouleursApp.noir,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CouleursApp.vert,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (choix != null) onChoisie(choix);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _etiquette(titre),
        GestureDetector(
          onTap: () => _choisir(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDE6D8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valeur == null ? 'JJ / MM / AAAA' : _formater(valeur!),
                    style: TextStyle(
                      fontSize: 13,
                      color: valeur == null
                          ? const Color(0xFF8A8A8A)
                          : CouleursApp.noir,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Color(0xFF555555),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
