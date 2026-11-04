import 'package:deme_mali_mobile/pages/authentification/connexion.dart';
import 'package:deme_mali_mobile/pages/beneficiaire/widgets/grille_actions.dart';
import 'package:deme_mali_mobile/pages/donateur/liste_demande_don/liste_demandes_don.dart';
import 'package:deme_mali_mobile/pages/donateur/organisation/detail_organisation/detail_organisation_page.dart';
import 'package:deme_mali_mobile/pages/donateur/accueil_donateur.dart';
import 'package:deme_mali_mobile/controllers/demande_aide_controller.dart';
import 'package:deme_mali_mobile/controllers/categorie_demande_controller.dart';
import 'package:deme_mali_mobile/controllers/notification_controller.dart';
import 'package:deme_mali_mobile/models/demande_aide.dart';
import 'package:deme_mali_mobile/models/organisation_partenaire.dart';
import 'package:deme_mali_mobile/widgets/barre_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _DemandesVides extends DemandeAideController {
  @override
  Future<List<DemandeAide>> build() async => [];
}

void main() {
  testWidgets('connexion sans débordement sur téléphone avec clavier', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: ConnexionPage()));
    await tester.enterText(find.byType(TextField).first, '70000000');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('actions et navigation sans débordement sur téléphone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: Scaffold(
            bottomNavigationBar: BarreNavigation(indexSelectionne: 0, onTap: (_) {}),
            body: SingleChildScrollView(
              child: GrilleActions(
                onDemanderAide: () {},
                onMesDemandes: () {},
                onSuiviAides: () {},
                onAidesRecues: () {},
              ),
            ),
          ),
        );
      }),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('liste des demandes utilisable avec le clavier sur petit téléphone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demandeAideControllerProvider.overrideWith(_DemandesVides.new),
        categorieDemandeControllerProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp(
        home: Builder(builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewInsets: const EdgeInsets.only(bottom: 260),
          ),
          child: const ListeDemandesDonPage(donateurId: 1, prenom: 'Awa'),
        )),
      ),
    ));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('détail organisation sans chevauchement sur petit téléphone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final organisation = OrganisationPartenaire(
      id: 1,
      nomOrganisation: 'Association pour les familles de Bamako',
      typeOrganisation: 'ASSOCIATION',
      ville: 'Bamako',
      description: 'Une organisation qui accompagne les familles et les enfants.',
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: DetailOrganisationPage(
          organisation: organisation,
          donateurId: 1,
          prenom: 'Awa',
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('accueil donateur sans chevauchement sur téléphone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        demandeAideControllerProvider.overrideWith(_DemandesVides.new),
        nombreNotificationsNonLuesProvider.overrideWithValue(0),
      ],
      child: MaterialApp(
        home: Builder(builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.3),
          ),
          child: const AccueilDonateurPage(
            prenom: 'Awa Coulibaly',
            donateurId: 1,
          ),
        )),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
