import 'dart:async';
import 'dart:convert';

/// Surveille la date d'expiration du JWT et évite plusieurs déconnexions
/// simultanées lorsque plusieurs requêtes reçoivent 401.
class SessionExpiration {
  static Future<void> Function()? onSessionExpiree;

  static Timer? _minuteur;
  static String? _jetonSurveille;
  static String? _dernierJetonExpire;

  static DateTime? dateExpiration(String jeton) {
    final parties = jeton.split('.');
    if (parties.length != 3) return null;

    try {
      final contenu = utf8.decode(
        base64Url.decode(base64Url.normalize(parties[1])),
      );
      final donnees = jsonDecode(contenu);
      if (donnees is! Map<String, dynamic>) return null;
      final exp = donnees['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  static bool estExpire(String jeton, {DateTime? maintenant}) {
    final expiration = dateExpiration(jeton);
    return expiration != null &&
        !expiration.isAfter((maintenant ?? DateTime.now()).toUtc());
  }

  static void surveiller(String? jeton) {
    if (jeton == null || jeton.isEmpty) {
      arreter();
      return;
    }
    if (jeton == _jetonSurveille) {
      if (estExpire(jeton)) unawaited(expirer(jeton));
      return;
    }

    _minuteur?.cancel();
    _jetonSurveille = jeton;
    if (jeton == _dernierJetonExpire) return;
    _dernierJetonExpire = null;

    final expiration = dateExpiration(jeton);
    if (expiration == null) return;

    final attente = expiration.difference(DateTime.now().toUtc());
    if (attente <= Duration.zero) {
      unawaited(expirer(jeton));
    } else {
      _minuteur = Timer(attente, () => unawaited(expirer(jeton)));
    }
  }

  static Future<void> expirer(String jeton) async {
    if (jeton == _dernierJetonExpire) return;
    if (_jetonSurveille != null && _jetonSurveille != jeton) return;

    _dernierJetonExpire = jeton;
    _minuteur?.cancel();
    await onSessionExpiree?.call();
  }

  static void arreter() {
    _minuteur?.cancel();
    _minuteur = null;
    _jetonSurveille = null;
  }
}
