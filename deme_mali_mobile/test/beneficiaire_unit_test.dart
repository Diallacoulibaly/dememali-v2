import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:deme_mali_mobile/controllers/connexion_controller.dart';
import 'package:deme_mali_mobile/models/reponse_connexion.dart';
import 'package:deme_mali_mobile/models/demande_aide.dart';
import 'package:deme_mali_mobile/models/article_demande.dart';

// Formatter de test reproduisant la logique de l'etape 2 montant
class _SeparateurMilliersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texteChiffres = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (texteChiffres.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formate = texteChiffres.replaceAllMapped(regex, (m) => '${m[1]} ');
    return TextEditingValue(
      text: formate,
      selection: TextSelection.collapsed(offset: formate.length),
    );
  }
}

void main() {
  group('Tests Formattage Montant Étape 2', () {
    final formatter = _SeparateurMilliersFormatter();

    test('Formate les milliers correctement avec un espace', () {
      final res50k = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '50000'),
      );
      expect(res50k.text, '50 000');

      final res1M = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '1250000'),
      );
      expect(res1M.text, '1 250 000');
    });

    test('Supprime les caractères non numériques', () {
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'abc1500xyz'),
      );
      expect(res.text, '1 500');
    });

    test('Gère le texte vide sans planter', () {
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: ''),
      );
      expect(res.text, '');
    });
  });

  group('Tests ConnexionController', () {
    test('Refuse les identifiants vides', () async {
      final controller = ConnexionController();
      final res = await controller.connecter(telephone: '', motDePasse: '');
      expect(res, isFalse);
      expect(controller.erreur, contains('remplir tous les champs'));
    });
  });

  group('Tests Désérialisation Modèles', () {
    test('ReponseConnexion parse JSON correctement', () {
      final json = {
        'accessToken': 'jwt-test-token-123',
        'utilisateur': {
          'id': 42,
          'nom': 'Traore',
          'prenom': 'Oumar',
          'telephone': '77889900',
          'role': 'BENEFICIAIRE'
        }
      };
      final reponse = ReponseConnexion.fromJson(json);
      expect(reponse.accessToken, 'jwt-test-token-123');
      expect(reponse.utilisateur.id, 42);
      expect(reponse.utilisateur.prenom, 'Oumar');
      expect(reponse.utilisateur.role, 'BENEFICIAIRE');
    });

    test('ArticleDemande parse JSON correctement', () {
      final json = {
        'id': 1,
        'designation': 'Sac de riz 50kg',
        'quantiteDemandee': 2,
        'unite': 'sac',
        'prixUnitaireEstime': 25000.0,
      };
      final article = ArticleDemande.fromJson(json);
      expect(article.id, 1);
      expect(article.designation, 'Sac de riz 50kg');
      expect(article.quantiteDemandee, 2);
      expect(article.unite, 'sac');
      expect(article.prixUnitaireEstime, 25000.0);
      expect(article.sousTotal, 50000.0);
    });

    test('DemandeAide parse JSON avec articles', () {
      final json = {
        'id': 10,
        'titre': 'Aide rentrée scolaire',
        'descriptionSituation': 'Famille nécessiteuse',
        'statut': 'EN_ATTENTE',
        'typeDemandeAide': 'MATERIELLE',
        'montantNecessaire': 45000.0,
        'articles': [
          {
            'id': 5,
            'designation': 'Cahiers et stylos',
            'quantiteDemandee': 10,
            'unite': 'lot',
            'prixUnitaireEstime': 4500.0,
          }
        ]
      };
      final demande = DemandeAide.fromJson(json);
      expect(demande.id, 10);
      expect(demande.titre, 'Aide rentrée scolaire');
      expect(demande.statut, 'EN_ATTENTE');
      expect(demande.articles.length, 1);
      expect(demande.articles.first.designation, 'Cahiers et stylos');
    });
  });
}

