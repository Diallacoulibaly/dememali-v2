import 'dart:convert';

import 'package:deme_mali_mobile/repositories/http_client_provider.dart';
import 'package:deme_mali_mobile/repositories/session_expiration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

String jetonAvecExpiration(DateTime expiration) {
  final corps = base64Url.encode(utf8.encode(jsonEncode({
    'exp': expiration.millisecondsSinceEpoch ~/ 1000,
  })));
  return 'entete.$corps.signature';
}

void main() {
  tearDown(() {
    SessionExpiration.arreter();
    SessionExpiration.onSessionExpiree = null;
  });

  test('un jeton expiré déconnecte avant tout appel réseau', () async {
    final jeton = jetonAvecExpiration(DateTime.now().subtract(const Duration(hours: 1)));
    var deconnexions = 0;
    SessionExpiration.onSessionExpiree = () async => deconnexions++;
    final client = ClientAuthentifie(
      MockClient((_) async => fail('La requête ne doit pas être envoyée')),
      () async => jeton,
    );
    addTearDown(client.close);

    await expectLater(
      client.get(Uri.parse('https://exemple.test/api/demandes-aide')),
      throwsA(isA<http.ClientException>()),
    );
    expect(deconnexions, 1);
  });

  test('un jeton stocké expiré déconnecte sans requête réseau', () async {
    final jeton = jetonAvecExpiration(
      DateTime.now().subtract(const Duration(hours: 2)),
    );
    var deconnexions = 0;
    SessionExpiration.onSessionExpiree = () async => deconnexions++;

    SessionExpiration.surveiller(jeton);
    await Future<void>.delayed(Duration.zero);

    expect(deconnexions, 1);
  });

  test('une réponse 401 déconnecte une seule fois', () async {
    final jeton = jetonAvecExpiration(DateTime.now().add(const Duration(hours: 1)));
    var deconnexions = 0;
    SessionExpiration.onSessionExpiree = () async => deconnexions++;
    final client = ClientAuthentifie(
      MockClient((requete) async {
        expect(requete.headers['Authorization'], 'Bearer $jeton');
        return http.Response('', 401);
      }),
      () async => jeton,
    );
    addTearDown(client.close);

    await client.get(Uri.parse('https://exemple.test/api/demandes-aide'));
    await client.get(Uri.parse('https://exemple.test/api/dons'));
    expect(deconnexions, 1);
  });
}
