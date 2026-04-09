import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../config/online_config.dart';
import '../firebase/firebase_bootstrap.dart';
import '../models/challenge.dart';
import 'friends_service.dart';
import 'player_prefs.dart';

class ChallengeService {
  ChallengeService._();

  static const Duration _kOpTimeout = Duration(seconds: 6);

  static Future<void> _ensureAuth() async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (_) {}
  }

  static String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  static bool get _ready {
    try {
      return kFirebaseOnlineFeaturesEnabled && Firebase.apps.isNotEmpty && _myUid != null;
    } catch (_) {
      return false;
    }
  }

  static int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  /// Risk round: once per player, you may arm a boost for the next run inside this challenge.
  /// If the run scores 0, it counts as 0 and marks risk as used.
  static int applyRiskScore({required int rawScore}) {
    if (rawScore <= 0) return 0;
    return (rawScore * 1.25).round();
  }

  static Future<String?> createChallenge({
    required String toUid,
    required ChallengeDuration duration,
  }) async {
    await _ensureAuth();
    if (!_ready) {
      return null;
    }
    final String fromUid = _myUid!;
    final String fromName = await PlayerPrefs.getDisplayName();
    final String toNameResolved = await FriendsService.displayNameForUid(toUid);
    final String toName = toNameResolved == toUid ? 'Player' : toNameResolved;
    final int createdAt = _nowMs();
    final int endsAt = createdAt + duration.duration.inMilliseconds;

    final DatabaseReference ref = FirebaseBootstrap.db.ref('challenges').push();
    final String id = ref.key!;
    final Challenge c = Challenge(
      id: id,
      createdAtMs: createdAt,
      endsAtMs: endsAt,
      fromUid: fromUid,
      toUid: toUid,
      fromName: fromName,
      toName: toName,
      status: ChallengeStatus.pending,
      fromBest: 0,
      toBest: 0,
      fromBestCombo: 1,
      toBestCombo: 1,
      fromRiskUsed: false,
      toRiskUsed: false,
      fromRiskArmed: false,
      toRiskArmed: false,
    );
    await ref.set(c.toJson());
    return id;
  }

  static Stream<List<Challenge>> watchMyChallenges() async* {
    // Always emit quickly so UI never spins forever.
    yield <Challenge>[];

    try {
      await _ensureAuth().timeout(_kOpTimeout);
    } catch (_) {
      return;
    }

    if (!_ready) return;
    final String me = _myUid!;
    final Query q = FirebaseBootstrap.db.ref('challenges').orderByChild('createdAtMs').limitToLast(200);
    try {
      await for (final DatabaseEvent event in q.onValue) {
        final Object? raw = event.snapshot.value;
        if (raw is! Map) {
          yield <Challenge>[];
          continue;
        }
        final List<Challenge> out = <Challenge>[];
        raw.forEach((Object? k, Object? v) {
          if (k == null || v is! Map) return;
          final Challenge c = Challenge.fromMap(k.toString(), Map<Object?, Object?>.from(v));
          if (c.involves(me)) out.add(c);
        });
        out.sort((Challenge a, Challenge b) => b.createdAtMs.compareTo(a.createdAtMs));
        yield out;
      }
    } catch (_) {
      // Keep UI usable (already yielded empty list).
      return;
    }
  }

  static Future<void> accept(String challengeId) async {
    await _ensureAuth();
    if (!_ready) return;
    final String me = _myUid!;
    final DataSnapshot snap = await FirebaseBootstrap.db.ref('challenges/$challengeId').get();
    if (!snap.exists || snap.value is! Map) return;
    final Challenge c = Challenge.fromMap(challengeId, Map<Object?, Object?>.from(snap.value! as Map));
    if (c.status != ChallengeStatus.pending || me != c.toUid) return;
    await FirebaseBootstrap.db.ref('challenges/$challengeId').update(<String, Object?>{
      'status': ChallengeStatus.active.name,
    });
  }

  static Future<void> decline(String challengeId) async {
    await _ensureAuth();
    if (!_ready) return;
    final String me = _myUid!;
    final DataSnapshot snap = await FirebaseBootstrap.db.ref('challenges/$challengeId').get();
    if (!snap.exists || snap.value is! Map) return;
    final Challenge c = Challenge.fromMap(challengeId, Map<Object?, Object?>.from(snap.value! as Map));
    if (c.status != ChallengeStatus.pending || me != c.toUid) return;
    await FirebaseBootstrap.db.ref('challenges/$challengeId').update(<String, Object?>{
      'status': ChallengeStatus.declined.name,
    });
  }

  static Future<void> cancel(String challengeId) async {
    await _ensureAuth();
    if (!_ready) return;
    final String me = _myUid!;
    final DataSnapshot snap = await FirebaseBootstrap.db.ref('challenges/$challengeId').get();
    if (!snap.exists || snap.value is! Map) return;
    final Challenge c = Challenge.fromMap(challengeId, Map<Object?, Object?>.from(snap.value! as Map));
    if (c.status != ChallengeStatus.pending || me != c.fromUid) return;
    await FirebaseBootstrap.db.ref('challenges/$challengeId').update(<String, Object?>{
      'status': ChallengeStatus.cancelled.name,
    });
  }

  static Future<void> armRisk(String challengeId, {required bool armed}) async {
    await _ensureAuth();
    if (!_ready) return;
    final String me = _myUid!;
    final DatabaseReference ref = FirebaseBootstrap.db.ref('challenges/$challengeId');
    final DataSnapshot snap = await ref.get();
    if (!snap.exists || snap.value is! Map) return;
    final Challenge c = Challenge.fromMap(challengeId, Map<Object?, Object?>.from(snap.value! as Map));
    if (c.status != ChallengeStatus.active) return;
    if (c.isOver) return;

    if (me == c.fromUid) {
      if (c.fromRiskUsed) return;
      await ref.update(<String, Object?>{'fromRiskArmed': armed});
    } else if (me == c.toUid) {
      if (c.toRiskUsed) return;
      await ref.update(<String, Object?>{'toRiskArmed': armed});
    }
  }

  /// Call after a run ends to update best score inside active challenges.
  static Future<void> submitRun({required int score, required int bestCombo}) async {
    await _ensureAuth();
    if (!_ready) return;

    final String me = _myUid!;
    final int now = _nowMs();

    final DataSnapshot snap = await FirebaseBootstrap.db.ref('challenges').get();
    if (!snap.exists || snap.value is! Map) return;
    final Map<Object?, Object?> all = snap.value! as Map<Object?, Object?>;

    for (final MapEntry<Object?, Object?> e in all.entries) {
      if (e.key == null || e.value is! Map) continue;
      final String id = e.key.toString();
      final Challenge c = Challenge.fromMap(id, Map<Object?, Object?>.from(e.value! as Map));
      if (!c.involves(me)) continue;
      if (c.status != ChallengeStatus.active) continue;
      if (now >= c.endsAtMs) {
        await FirebaseBootstrap.db.ref('challenges/$id').update(<String, Object?>{
          'status': ChallengeStatus.completed.name,
        });
        continue;
      }

      final DatabaseReference ref = FirebaseBootstrap.db.ref('challenges/$id');
      if (me == c.fromUid) {
        final bool risk = c.fromRiskArmed && !c.fromRiskUsed;
        final int challengeScore = risk ? applyRiskScore(rawScore: score) : score;
        final bool improve = challengeScore > c.fromBest;
        final Map<String, Object?> up = <String, Object?>{};
        if (risk) {
          up['fromRiskArmed'] = false;
          up['fromRiskUsed'] = true;
        }
        if (improve) {
          up['fromBest'] = challengeScore;
          up['fromBestCombo'] = bestCombo;
        }
        if (up.isNotEmpty) await ref.update(up);
      } else if (me == c.toUid) {
        final bool risk = c.toRiskArmed && !c.toRiskUsed;
        final int challengeScore = risk ? applyRiskScore(rawScore: score) : score;
        final bool improve = challengeScore > c.toBest;
        final Map<String, Object?> up = <String, Object?>{};
        if (risk) {
          up['toRiskArmed'] = false;
          up['toRiskUsed'] = true;
        }
        if (improve) {
          up['toBest'] = challengeScore;
          up['toBestCombo'] = bestCombo;
        }
        if (up.isNotEmpty) await ref.update(up);
      }
    }
  }
}

