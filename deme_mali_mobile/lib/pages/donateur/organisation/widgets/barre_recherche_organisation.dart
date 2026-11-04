import 'package:flutter/material.dart';
import '/../styles/couleurs.dart';

class BarreRechercheOrganisation extends StatelessWidget {
  final ValueChanged<String> onRechercheChangee;
  const BarreRechercheOrganisation({super.key, required this.onRechercheChangee});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onRechercheChangee,
      decoration: InputDecoration(
        hintText: 'Rechercher une organisation...',
        prefixIcon: const Icon(Icons.search, color: CouleursApp.vert),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CouleursApp.vert.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CouleursApp.vert, width: 1.5),
        ),
      ),
    );
  }
}
