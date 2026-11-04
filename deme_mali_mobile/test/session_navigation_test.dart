import 'dart:convert';

import 'package:deme_mali_mobile/main.dart';
import 'package:deme_mali_mobile/pages/authentification/connexion.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('un jeton stocké expiré ramène à la connexion', (tester) async {
    final expiration = DateTime.now().subtract(const Duration(hours: 1));
    final corps = base64Url.encode(utf8.encode(jsonEncode({
      'exp': expiration.millisecondsSinceEpoch ~/ 1000,
    })));
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'entete.$corps.signature',
    });

    await tester.pumpWidget(const DemeMaliApp());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ConnexionPage), findsOneWidget);
    expect(await const FlutterSecureStorage().read(key: 'accessToken'), isNull);
  });
}
