import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../models/donnees_structure.dart';
import '../../../styles/couleurs.dart';
import '../widgets/boutons_etapes.dart';
import '../widgets/champs_inscription.dart';
import '../widgets/entete_etapes.dart';
import 'informations_structure_etape3.dart';

class InformationsStructureEtape2Page extends StatefulWidget {
  final int organisationId;
  final DonneesStructureEtape1 etape1;

  const InformationsStructureEtape2Page({
    super.key,
    required this.organisationId,
    required this.etape1,
  });

  @override
  State<InformationsStructureEtape2Page> createState() =>
      _InformationsStructureEtape2PageState();
}

class _InformationsStructureEtape2PageState
    extends State<InformationsStructureEtape2Page> {
  final emailController = TextEditingController();

  String? nomFichier;
  String? tailleFichier;
  Uint8List? octetsFichier;
  bool selectionEnCours = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _actualiser([String? _]) => setState(() {});

  bool get formulaireValide {
    final email = emailController.text.trim();
    final emailValide = email.isNotEmpty && email.contains('@');
    return emailValide && nomFichier != null;
  }

  Future<void> _choisirFichier() async {
    setState(() => selectionEnCours = true);
    try {
      final fichiers = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (fichiers.isNotEmpty) {
        final fichier = fichiers.first;
        final nom = fichier.name;
        final octets = fichier.lengthSync() ?? (await fichier.length()) ?? 0;
        String tailleLisible;
        if (octets >= 1024 * 1024) {
          tailleLisible = '${(octets / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else {
          tailleLisible = '${(octets / 1024).toStringAsFixed(0)} KB';
        }

        final bytes = await fichier.readAsBytes();

        setState(() {
          nomFichier = nom;
          tailleFichier = tailleLisible;
          octetsFichier = bytes;
        });
      }
    } catch (e) {
      debugPrint('Erreur sélection fichier : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de sélectionner le fichier.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => selectionEnCours = false);
      }
    }
  }

  void _supprimerFichier() {
    setState(() {
      nomFichier = null;
      tailleFichier = null;
      octetsFichier = null;
    });
  }

  void _continuer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsStructureEtape3Page(
          organisationId: widget.organisationId,
          etape2: DonneesStructureEtape2(
            etape1: widget.etape1,
            nomDocument: nomFichier,
            octetsDocument: octetsFichier,
            email: emailController.text.trim(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EnteteEtapes(
                      etape: 2,
                      total: 3,
                      titre: 'Informations de la stucture',
                      sousTitre: 'Ajoutez les documents nécessaires pour '
                          'nous aider à vérifier votre existance.',
                    ),
                    const SizedBox(height: 22),

                    // ZONE D'UPLOAD DE JUSTIFICATIF
                    _zoneUpload(),

                    const SizedBox(height: 22),

                    ChampInscription(
                      titre: 'Adresse e-mail',
                      indication: 'Exemple : contact@organisation.ml',
                      controller: emailController,
                      typeClavier: TextInputType.emailAddress,
                      onChanged: _actualiser,
                    ),
                  ],
                ),
              ),
            ),

            // BOUTONS FIXES EN BAS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: BoutonsEtapes(
                onRetour: () => Navigator.pop(context),
                onSuivant: formulaireValide ? _continuer : null,
                texteSuivant: 'Continuer',
                afficherFleche: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoneUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: CouleursApp.vert,
            width: 1.2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Ajouter un justificatif',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF, JPG ou PNG',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 16),

            if (nomFichier == null)
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: selectionEnCours ? null : _choisirFichier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: selectionEnCours
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Choisir un fichier',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0EAE2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      size: 24,
                      color: CouleursApp.vert,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomFichier!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CouleursApp.noir,
                            ),
                          ),
                          if (tailleFichier != null)
                            Text(
                              tailleFichier!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF777777),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      onPressed: _supprimerFichier,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
