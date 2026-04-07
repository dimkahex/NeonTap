import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../config/online_config.dart';
import '../models/leaderboard_entry.dart';
import 'local_stats.dart';
import 'player_prefs.dart';

/// Global leaderboard under `leaderboard/global/{uid}`.
class LeaderboardService {
  LeaderboardService._();

  /// Last Firebase / RTDB issue (null when healthy).
  static final ValueNotifier<String?> status = ValueNotifier<String?>(null);

  static bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _ensureAuth() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      status.value = null;
    } catch (e) {
      // Offline or missing config.
      status.value =
          'Firebase init/auth failed: $e\nCheck internet, enable Anonymous Auth, publish RTDB rules, and ensure /leaderboard/global is readable with .indexOn(\"score\").';
    }
  }

  /// Локальный «глобальный» топ: один игрок — твой лучший счёт из [LocalStats].
  static Future<List<LeaderboardEntry>> loadLocalGlobalLeaderboard() async {
    final (int score, int combo) = await LocalStats.getBest();
    final String name = await PlayerPrefs.getDisplayName();
    return <LeaderboardEntry>[
      LeaderboardEntry(
        uid: 'local',
        displayName: name,
        score: score,
        bestCombo: combo,
        isMe: true,
      ),
    ];
  }

  /// Pushes local best to RTDB if it beats the stored server best (or missing).
  static Future<void> syncBestFromLocal({
    required int bestScore,
    required int bestCombo,
  }) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return;
    }
    await _ensureAuth();
    if (!_firebaseReady) {
      return;
    }
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    final String displayName = await PlayerPrefs.getDisplayName();
    final DatabaseReference ref = FirebaseDatabase.instance.ref('leaderboard/global/$uid');
    final DataSnapshot snap = await ref.get();
    final int prev = _readScore(snap);
    if (bestScore <= prev) {
      return;
    }
    try {
      await ref.set(<String, Object?>{
        'displayName': displayName,
        'score': bestScore,
        'bestCombo': bestCombo,
        'updatedAt': ServerValue.timestamp,
      });
      status.value = null;
    } catch (e) {
      status.value = 'RTDB write failed: $e';
    }
  }

  static int _readScore(DataSnapshot snap) {
    if (!snap.exists || snap.value == null) {
      return 0;
    }
    if (snap.value is! Map) {
      return 0;
    }
    final Map<Object?, Object?> m = snap.value! as Map<Object?, Object?>;
    return (m['score'] as num?)?.toInt() ?? 0;
  }

  static Future<bool> ensureReady() async {
    await _ensureAuth();
    return _firebaseReady;
  }

  /// Top [limit] players by score (descending). Waits for auth before subscribing.
  static Stream<List<LeaderboardEntry>> watchGlobalTop({int limit = 100}) async* {
    if (!kFirebaseOnlineFeaturesEnabled) {
      yield await loadLocalGlobalLeaderboard();
      return;
    }

    // Always emit something quickly so UI never spins forever.
    yield await loadLocalGlobalLeaderboard();

    // Try to connect/auth with a timeout (otherwise StreamBuilder can stay `waiting` indefinitely).
    try {
      await _ensureAuth().timeout(const Duration(seconds: 6));
    } catch (e) {
      status.value = 'Firebase init/auth timed out: $e';
      return;
    }

    await _ensureAuth();
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;
    if (Firebase.apps.isEmpty || myUid == null) {
      // Can't connect/auth — show local best so the screen isn't empty.
      yield await loadLocalGlobalLeaderboard();
      return;
    }
    final Query q = FirebaseDatabase.instance
        .ref('leaderboard/global')
        .orderByChild('score')
        .limitToLast(limit);

    try {
      await for (final DatabaseEvent event in q.onValue) {
        final Object? raw = event.snapshot.value;
        if (raw is! Map) {
          yield <LeaderboardEntry>[];
          continue;
        }
        final List<LeaderboardEntry> rows = <LeaderboardEntry>[];
        raw.forEach((Object? k, Object? v) {
          if (k == null || v is! Map) {
            return;
          }
          final String uid = k.toString();
          final Map<Object?, Object?> vm = Map<Object?, Object?>.from(v);
          rows.add(
            LeaderboardEntry.fromSnapshotMap(uid, vm).copyWith(
              isMe: uid == myUid,
            ),
          );
        });
        rows.sort((LeaderboardEntry a, LeaderboardEntry b) => b.score.compareTo(a.score));
        status.value = null;
        yield rows;
      }
    } catch (e) {
      status.value = 'RTDB subscription failed: $e';
      // Keep UI usable (local best already yielded).
      return;
    }
  }

  /// Updates display name; creates a leaderboard row from local bests if missing.
  static Future<void> pushDisplayName(String displayName) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return;
    }
    await _ensureAuth();
    if (!_firebaseReady) {
      return;
    }
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    final DatabaseReference ref = FirebaseDatabase.instance.ref('leaderboard/global/$uid');
    final DataSnapshot snap = await ref.get();
    final String dn = displayName.trim().isEmpty ? 'Player' : displayName.trim();
    if (!snap.exists) {
      final (int bestScore, int bestCombo) = await LocalStats.getBest();
      await ref.set(<String, Object?>{
        'displayName': dn,
        'score': bestScore,
        'bestCombo': bestCombo,
        'updatedAt': ServerValue.timestamp,
      });
      return;
    }
    await ref.update(<String, Object?>{
      'displayName': dn,
      'updatedAt': ServerValue.timestamp,
    });
  }
}
