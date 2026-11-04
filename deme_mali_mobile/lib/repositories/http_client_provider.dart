import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'auth_repository.dart';
import 'session_expiration.dart';

class ClientAuthentifie extends http.BaseClient {
  final http.Client _interne;
  final Future<String?> Function() _lireToken;

  ClientAuthentifie(this._interne, this._lireToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _lireToken();
    if (token != null && token.isNotEmpty) {
      if (SessionExpiration.estExpire(token)) {
        await SessionExpiration.expirer(token);
        throw http.ClientException('Votre session a expiré.', request.url);
      }
      SessionExpiration.surveiller(token);
      request.headers['Authorization'] = 'Bearer $token';
    }
    final reponse = await _interne.send(request);
    if (reponse.statusCode == 401 && token != null && token.isNotEmpty) {
      await SessionExpiration.expirer(token);
    }
    return reponse;
  }

  @override
  void close() => _interne.close();
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = ClientAuthentifie(
    http.Client(),
    AuthRepository().recupererToken,
  );
  ref.onDispose(client.close);
  return client;
});
