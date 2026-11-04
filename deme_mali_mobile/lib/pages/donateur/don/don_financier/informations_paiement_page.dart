
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/styles/couleurs.dart';
import '/controllers/paiement_controller.dart';
import 'don_reussi_page.dart';

class InformationsPaiementPage extends ConsumerStatefulWidget {
  final double montant;
  final bool anonyme;
  final String modePaiement;
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;
  final String prenom;

  const InformationsPaiementPage({
    super.key,
    required this.montant,
    required this.anonyme,
    required this.modePaiement,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  ConsumerState<InformationsPaiementPage> createState() =>
      _InformationsPaiementPageState();
}

class _InformationsPaiementPageState
    extends ConsumerState<InformationsPaiementPage> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _pinController = TextEditingController();

  bool _pinVisible = false;
  bool _chargement = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String get _nomModePaiement {
    switch (widget.modePaiement) {
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'WAVE':
        return 'Wave';
      case 'MOVE_MONEY':
        return 'Moov Money';
      default:
        return widget.modePaiement;
    }
  }

  Future<void> _confirmerPaiement() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    try {
      final paiement = await ref
          .read(paiementDonControllerProvider)
          .effectuerPaiement(
        montant: widget.montant,
        numeroTelephone: _telephoneController.text.trim(),
        codeSecret: _pinController.text.trim(),
        donateurId: widget.donateurId,
        modePaiement: widget.modePaiement,
        anonyme: widget.anonyme,
        demandeAideId: widget.demandeAideId,
        organisationPartenaireId:
        widget.organisationPartenaireId,
      );

      if (!mounted) return;

      if (paiement.statut == 'CONFIRME') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonReussiPage(
              montant: widget.montant,
              modePaiement: _nomModePaiement,
              prenom: widget.prenom,
              donateurId: widget.donateurId,
            ),
          ),
        );
      } else {
        final message = paiement.statut == 'ECHEC'
            ? 'Code PIN incorrect. Veuillez réessayer.'
            : 'Paiement non confirmé : ${paiement.statut}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: CouleursApp.blanc,
              ),
            ),
            backgroundColor: CouleursApp.noir,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du paiement : $e',
            style: const TextStyle(
              color: CouleursApp.blanc,
            ),
          ),
          backgroundColor: CouleursApp.noir,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _chargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: CouleursApp.blanc,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: IconButton(
                        onPressed: _chargement
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 21,
                        ),
                        color: CouleursApp.noir,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Paiement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),

                const SizedBox(height: 20),

                // Explication directement sous le titre Paiement
                const Text(
                  'Finalisez votre paiement',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 12,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 30),

                // Numéro de téléphone
                _labelChamp('Numéro de téléphone'),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  style: const TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 14,
                  ),
                  decoration: _decoration(
                    label: 'Entrez votre numéro',
                    prefixIcon: Icons.phone_android_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le numéro de téléphone est obligatoire.';
                    }

                    final chiffres =
                    value.replaceAll(RegExp(r'\D'), '');

                    if (chiffres.length != 8) {
                      return 'Le numéro doit contenir exactement 8 chiffres.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // Code PIN
                _labelChamp('Code PIN'),

                const SizedBox(height: 9),

                TextFormField(
                  controller: _pinController,
                  obscureText: !_pinVisible,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                  decoration: _decoration(
                    label: 'Entrez votre code PIN',
                    prefixIcon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      onPressed: () {
                        setState(() {
                          _pinVisible = !_pinVisible;
                        });
                      },
                      icon: Icon(
                        _pinVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: CouleursApp.vert,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le code PIN est obligatoire.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _chargement
                        ? null
                        : _confirmerPaiement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CouleursApp.vert,
                      foregroundColor: CouleursApp.blanc,
                      disabledBackgroundColor: CouleursApp.vert,
                      disabledForegroundColor: CouleursApp.blanc,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _chargement
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: CouleursApp.blanc,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Confirmer le paiement',
                      style: TextStyle(
                        color: CouleursApp.blanc,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Libellé des champs
  Widget _labelChamp(String texte) {
    return Text(
      texte,
      style: const TextStyle(
        color: CouleursApp.noir,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Style commun des champs
  InputDecoration _decoration({
    required String label,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        color: Colors.black38,
        fontSize: 13,
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 11,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: CouleursApp.vert,
        size: 20,
      ),
      filled: true,
      fillColor: CouleursApp.blanc,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: CouleursApp.vert,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
    );
  }
}
