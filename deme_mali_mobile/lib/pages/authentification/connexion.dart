import 'package:flutter/material.dart';

import '../../controllers/connexion_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/beneficiaire_repository.dart';
import '../../styles/couleurs.dart';
import '../beneficiaire/accueil_beneficiaire.dart';
import '../navigation_donateur_page.dart';
import 'widgets/champ_connexion.dart';
import 'widgets/bouton_connexion.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final telephoneController = TextEditingController();
  final motDePasseController = TextEditingController();
  final ConnexionController controller = ConnexionController();

  bool afficherMotDePasse = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_actualiser);
  }

  void _actualiser() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_actualiser);
    controller.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    final succes = await controller.connecter(
      telephone: telephoneController.text.trim(),
      motDePasse: motDePasseController.text,
    );

    if (!mounted) return;

    if (!succes) {
      final messageErreur = controller.erreur ?? 'Erreur de connexion.';
      final lowerMsg = messageErreur.toLowerCase();

      if (lowerMsg.contains('attente') || lowerMsg.contains('validation')) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Text('Compte en attente'),
              ],
            ),
            content: Text(
              messageErreur,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Compris',
                  style: TextStyle(
                    color: CouleursApp.vert,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      if (lowerMsg.contains('refusé') || lowerMsg.contains('refuse')) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text('Compte refusé'),
              ],
            ),
            content: Text(
              messageErreur,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Fermer',
                  style: TextStyle(
                    color: CouleursApp.vert,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  messageErreur,
                  style: const TextStyle(fontSize: 13.5, height: 1.3),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2C3E50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final utilisateur = controller.resultat!.utilisateur;
    final role = utilisateur.role.trim().toUpperCase();

    if (role == 'BENEFICIAIRE' || role == 'BENEFICIARE') {
      String nomBeneficiaire = utilisateur.prenom;
      try {
        final repo = BeneficiaireRepository();
        final beneficiaire = await repo.getBeneficiaireById(utilisateur.id);
        final statut = (beneficiaire.statut ?? '').toUpperCase();
        final typeBeneficiaire = (beneficiaire.typeBeneficiaire ?? '').toUpperCase();

        if (typeBeneficiaire == 'STRUCTURE' &&
            beneficiaire.nomStructure != null &&
            beneficiaire.nomStructure!.trim().isNotEmpty) {
          nomBeneficiaire = beneficiaire.nomStructure!.trim();
        }

        if (statut == 'EN_ATTENTE') {
          await AuthRepository().deconnexion();
          if (!mounted) return;

          final bool estStructure = typeBeneficiaire == 'STRUCTURE';
          final String messageAttente = estStructure
              ? "Votre compte structure est en attente de validation par l'administrateur. Vous pourrez vous connecter dès que l'administrateur aura validé votre structure."
              : "Votre compte est en attente de validation par votre organisation partenaire. Vous pourrez vous connecter dès que l'organisation aura validé votre dossier.";

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Text('Compte en attente'),
                ],
              ),
              content: Text(
                messageAttente,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Compris',
                    style: TextStyle(
                      color: CouleursApp.vert,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        } else if (statut == 'REFUSE') {
          await AuthRepository().deconnexion();
          if (!mounted) return;

          final bool estStructure = typeBeneficiaire == 'STRUCTURE';
          final String messageRefus = estStructure
              ? "Votre compte structure a été refusé par l'administrateur."
              : "Votre inscription a été refusée par l'organisation partenaire.";

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: const [
                  Icon(Icons.cancel_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Compte refusé'),
                ],
              ),
              content: Text(
                messageRefus,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: CouleursApp.vert,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('Erreur lors de la vérification du statut du bénéficiaire : $e');
      }

      if (!mounted) return;
      if (await AuthRepository().recupererToken() == null) return;
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AccueilBeneficiairePage(
            prenomBeneficiaire: nomBeneficiaire,
          ),
        ),
        (route) => false,
      );
    } else if (role == 'DONATEUR') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationDonateurPage(
            prenom: utilisateur.prenom,
            donateurId: utilisateur.id,
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connexion réussie. Rôle : $role. '
                'La page correspondante reste à configurer.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'assets/images/logo_acceuil.png',
                  width: 95,
                  height: 85,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/logo_Acceuil.png',
                    width: 140,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error2, stackTrace2) => Image.asset(
                      'assets/images/logo_accueil.png',
                      width: 140,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Dèmè ',
                        style: TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Mali',
                        style: TextStyle(
                          color: CouleursApp.jaune,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Connectez-vous à votre compte Dèmè Mali.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),

              const SizedBox(height: 16),

              ChampConnexion(
                titre: 'Téléphone',
                indication: 'Entrez votre numéro de téléphone',
                controller: telephoneController,
                typeClavier: TextInputType.phone,
              ),

              const SizedBox(height: 12),

              ChampConnexion(
                titre: 'Mot de passe',
                indication: 'Entrez votre mot de passe',
                controller: motDePasseController,
                motDePasse: true,
                afficherMotDePasse: afficherMotDePasse,
                changerVisibilite: () {
                  setState(() {
                    afficherMotDePasse = !afficherMotDePasse;
                  });
                },
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La récupération du mot de passe sera ajoutée ensuite.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      fontSize: 11,
                      color: CouleursApp.vert,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              BoutonConnexion(
                chargement: controller.chargement,
                onPressed: _connecter,
              ),

              const SizedBox(height: 14),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      'Vous n’avez pas encore de compte ? ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'S’inscrire',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CouleursApp.vert,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
