import 'package:deme_mali_mobile/controllers/aide_distribuee_controller.dart';
import 'package:deme_mali_mobile/controllers/categorie_demande_controller.dart';
import 'package:deme_mali_mobile/controllers/preuve_distribution_controoller.dart';
import 'package:deme_mali_mobile/repositories/http_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('les lectures protégées utilisent le client avec jeton', () async {
    final chemins = <String>[];
    final transport = MockClient((requete) async {
      chemins.add(requete.url.path);
      expect(requete.headers['Authorization'], 'Bearer jeton-test');
      return http.Response('[]', 200);
    });
    final client = ClientAuthentifie(transport, () async => 'jeton-test');
    final container = ProviderContainer(overrides: [
      httpClientProvider.overrideWithValue(client),
    ]);
    addTearDown(container.dispose);

    expect(await container.read(categorieDemandeControllerProvider.future), isEmpty);
    expect(await container.read(aidesDistribueesParDemandeProvider(2).future), isEmpty);
    expect(await container.read(preuvesParDistributionProvider(3).future), isEmpty);
    expect(chemins, [
      '/api/categories-demande',
      '/api/aides-distribuees/demande/2',
      '/api/preuves-distribution/distribution/3',
    ]);
  });
}
