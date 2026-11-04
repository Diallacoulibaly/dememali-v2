import 'package:deme_mali_mobile/pages/donateur/liste_demande_don/widgets/entete_liste_demandes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la recherche et les catégories sont utilisables sur petit écran',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(313, 553));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String recherche = '';
    String categorie = 'Toutes';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EnteteListeDemandes(
          onRechercheChanged: (valeur) => recherche = valeur,
          categories: const ['Toutes', 'Éducation'],
          categorieSelectionnee: categorie,
          onCategorieChanged: (valeur) => categorie = valeur,
          nombreDemandes: 1,
        ),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'école');
    await tester.tap(find.text('Éducation'));

    expect(find.text('Urgence'), findsNothing);
    expect(recherche, 'école');
    expect(categorie, 'Éducation');
    expect(tester.takeException(), isNull);
  });
}
