import 'package:flutter_test/flutter_test.dart';
import 'package:deme_mali_mobile/models/donateur.dart';
import 'package:deme_mali_mobile/models/notification_item.dart';
import 'package:deme_mali_mobile/repositories/auth_repository.dart';

void main() {
  group('Tests Modèle Donateur & Photo de Profil', () {
    test('Donateur parse JSON avec photo', () {
      final json = {
        'id': 15,
        'nom': 'Coulibaly',
        'prenom': 'Fatoumata',
        'telephone': '76543210',
        'sexe': 'FEMININ',
        'paysId': 1,
        'paysNom': 'Mali',
        'photo': 'donateur_15_photo.jpg',
      };

      final donateur = Donateur.fromJson(json);
      expect(donateur.id, 15);
      expect(donateur.nom, 'Coulibaly');
      expect(donateur.prenom, 'Fatoumata');
      expect(donateur.nomComplet, 'Fatoumata Coulibaly');
      expect(donateur.photo, 'donateur_15_photo.jpg');
    });

    test('Donateur supporte photoUrl alternative et copyWith', () {
      final json = {
        'id': 20,
        'nom': 'Keita',
        'prenom': 'Modibo',
        'telephone': '65432109',
        'photoUrl': 'https://example.com/avatar.png',
      };

      final donateur = Donateur.fromJson(json);
      expect(donateur.photo, 'https://example.com/avatar.png');

      final maj = donateur.copyWith(photo: 'nouvelle_photo.jpg');
      expect(maj.photo, 'nouvelle_photo.jpg');
      expect(maj.id, 20);
      expect(maj.prenom, 'Modibo');
    });

    test('Construction de l’URL distante photo de profil', () {
      const nomPhoto = 'abc-123.jpg';
      final url = '${AuthRepository.baseUrl}/uploads/photos/$nomPhoto';
      expect(url, contains('/uploads/photos/abc-123.jpg'));
    });
  });

  group('Tests Notifications & Flux SSE', () {
    test('NotificationItem parse un événement SSE du backend', () {
      final sseJson = {
        'type': 'DON_RECU',
        'titre': 'Don reçu avec succès',
        'message': 'Votre don de 25 000 FCFA a été enregistré.',
        'timestamp': DateTime.now().toIso8601String(),
        'montant': 25000,
        'demandeId': 4,
      };

      final item = NotificationItem.fromJson(sseJson);
      expect(item.type, TypeNotification.donRecu);
      expect(item.titre, 'Don reçu avec succès');
      expect(item.montant, 25000);
      expect(item.demandeId, 4);
      expect(item.lu, isFalse);
    });

    test('NotificationItem calcule correctement la date formatée', () {
      final maintenant = DateTime.now();
      final itemRecent = NotificationItem(
        id: 'test_1',
        type: TypeNotification.systeme,
        titre: 'Test',
        message: 'Message test',
        date: maintenant,
      );
      expect(itemRecent.dateFormatee, 'À l’instant');
    });
  });
}

