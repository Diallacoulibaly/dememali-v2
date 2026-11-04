import 'package:deme_mali_mobile/repositories/http_client_provider.dart';
import 'package:deme_mali_mobile/repositories/like_organisation_repository.dart';
import 'package:deme_mali_mobile/repositories/organisation_partenaire_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('la liste et les favoris utilisent l’API et le jeton du donateur', () async {
    final chemins = <String>[];
    final transport = MockClient((requete) async {
      chemins.add(requete.url.path);
      expect(requete.url.hasScheme, isTrue);
      expect(requete.url.host, isNotEmpty);
      expect(requete.url.queryParameters['donateurId'], '10');
      expect(requete.headers['Authorization'], 'Bearer jeton-test');
      return http.Response(
        '[{"id":2,"nomOrganisation":"Association A","typeOrganisation":"ASSOCIATION","ville":"Bamako","statutValidation":"VALIDEE"}]',
        200,
      );
    });
    final client = ClientAuthentifie(transport, () async => 'jeton-test');
    final container = ProviderContainer(overrides: [
      httpClientProvider.overrideWithValue(client),
    ]);
    addTearDown(container.dispose);

    final organisations = await container.read(
      organisationsAvecLikesProvider(10).future,
    );
    expect(organisations.single.nomOrganisation, 'Association A');
    expect(chemins, contains('/api/organisations-partenaires/liste-avec-likes'));
  });

  test('la liste des favoris utilise le client authentifié partagé', () async {
    final transport = MockClient((requete) async {
      expect(requete.url.path, '/api/likes-organisations/donateur/10');
      expect(requete.headers['Authorization'], 'Bearer jeton-test');
      return http.Response('[]', 200);
    });
    final client = ClientAuthentifie(transport, () async => 'jeton-test');
    final container = ProviderContainer(overrides: [
      httpClientProvider.overrideWithValue(client),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(organisationsAimeesProvider(10).future), isEmpty);
  });
}
