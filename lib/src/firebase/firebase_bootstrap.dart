import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseBootstrap {
  static bool _started = false;
  static const String _kRtdbUrl = 'https://neonpulse-d7389-default-rtdb.europe-west1.firebasedatabase.app';

  /// Phase 1 behavior:
  /// - If Firebase isn't configured (no options / no native config), do nothing.
  /// - If configured, ensure anonymous sign-in.
  static Future<void> ensureGuestAuth() async {
    if (_started) return;
    _started = true;

    try {
      if (Firebase.apps.isEmpty) {
        // Without generated options, this will throw on most setups.
        // That's OK for Phase 1 offline-first.
        await Firebase.initializeApp();
      }
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
    } catch (_) {
      // ignore (offline / not configured yet)
    }
  }

  static FirebaseDatabase get db {
    // Always use explicit databaseURL: some google-services.json files don't contain firebase_url,
    // and `firebase_database` can otherwise target the wrong default host and hang.
    return FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _kRtdbUrl);
  }
}

