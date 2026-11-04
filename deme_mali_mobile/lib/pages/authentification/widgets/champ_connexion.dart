
import 'package:flutter/material.dart';

class ChampConnexion extends StatelessWidget {
  final String titre;
  final String indication;
  final TextEditingController controller;
  final bool motDePasse;
  final bool afficherMotDePasse;
  final VoidCallback? changerVisibilite;
  final TextInputType typeClavier;

  const ChampConnexion({
    super.key,
    required this.titre,
    required this.indication,
    required this.controller,
    this.motDePasse = false,
    this.afficherMotDePasse = false,
    this.changerVisibilite,
    this.typeClavier = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: typeClavier,
          obscureText: motDePasse && !afficherMotDePasse,
          decoration: InputDecoration(
            hintText: indication,
            hintStyle: const TextStyle(fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE7DFD2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE7DFD2),
              ),
            ),
            suffixIcon: motDePasse
                ? IconButton(
              onPressed: changerVisibilite,
              icon: Icon(
                afficherMotDePasse
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }
}
