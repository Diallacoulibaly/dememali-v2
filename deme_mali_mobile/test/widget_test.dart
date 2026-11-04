import 'package:flutter_test/flutter_test.dart';
import 'package:deme_mali_mobile/main.dart';

void main() {
  testWidgets('Dèmè Mali démarre correctement', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DemeMaliApp());
    // Avancer le temps pour que toutes les animations du splash screen s'achèvent
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.byType(DemeMaliApp), findsOneWidget);
  });
}
