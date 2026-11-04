
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/preuve_distribution.dart';

class PreuveDistributionRepository {
  final String baseUrl;
  final http.Client _client;

  PreuveDistributionRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<PreuveDistribution>> getByDistribution(
      int aideDistribueeId,
      ) async {
    final uri = Uri.parse(
      '$baseUrl/api/preuves-distribution/distribution/'
          '$aideDistribueeId',
    );

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les preuves de distribution '
            '(HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw const FormatException(
        'La réponse des preuves doit être une liste.',
      );
    }

    return decoded.map((element) {
      if (element is! Map<String, dynamic>) {
        throw const FormatException(
          'Format incorrect pour une preuve de distribution.',
        );
      }

      return PreuveDistribution.fromJson(element);
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}
