import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/lancement/ecran_lancement.dart';
import 'pages/authentification/connexion.dart';
import 'repositories/auth_repository.dart';
import 'repositories/session_expiration.dart';
import 'styles/couleurs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture les erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint('ERREUR FLUTTER : ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  // Capture les erreurs asynchrones non gérées
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('ERREUR NON CAPTURÉE : $error');
    debugPrintStack(stackTrace: stack);

    return true;
  };

  runApp(
    const ProviderScope(
      child: DemeMaliApp(),
    ),
  );
}

class DemeMaliApp extends StatefulWidget {
  const DemeMaliApp({super.key});

  @override
  State<DemeMaliApp> createState() => _DemeMaliAppState();
}

class _DemeMaliAppState extends State<DemeMaliApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionExpiration.onSessionExpiree = () async {
      await AuthRepository().deconnexion();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ConnexionPage()),
          (_) => false,
        );
      });
      WidgetsBinding.instance.scheduleFrame();
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _verifierSessionStockee();
    });
  }

  Future<void> _verifierSessionStockee() async {
    final jeton = await AuthRepository().recupererToken();
    if (!mounted) return;
    SessionExpiration.surveiller(jeton);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifierSessionStockee();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionExpiration.onSessionExpiree = null;
    SessionExpiration.arreter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Dèmè Mali',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: ThemeData(
        scaffoldBackgroundColor: CouleursApp.fond,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CouleursApp.vert,
        ),
        useMaterial3: true,
      ),
      home: const EcranLancement(),
    );
  }
}
