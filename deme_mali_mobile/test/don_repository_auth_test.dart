import 'package:deme_mali_mobile/repositories/don_repository.dart';
import 'package:deme_mali_mobile/repositories/http_client_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('la lecture des dons d’une demande transmet le jeton', () async {
    String? autorisation;
    final transport = MockClient((requete) async {
      autorisation = requete.headers['Authorization'];
      expect(requete.url.path, '/api/dons/demande/2');
      return http.Response('[]', 200);
    });
    final client = ClientAuthentifie(
      transport,
      () async => 'jeton-test',
    );
    final depot = DonRepository(
      baseUrl: 'http://localhost:8080',
      client: client,
    );

    expect(await depot.getByDemande(2), isEmpty);
    expect(autorisation, 'Bearer jeton-test');
    client.close();
  });
}
