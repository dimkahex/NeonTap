import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../config/online_config.dart';
import '../models/leaderboard_entry.dart';
import 'leaderboard_service.dart';
import 'share_code_local.dart';

/// Friend codes + `users/{uid}/friends/{friendUid}`.
class FriendsService {
  FriendsService._();

  static const Duration _kOpTimeout = Duration(seconds: 6);

  /// Last Firebase / RTDB issue related to friends/profile features.
  static final ValueNotifier<String?> status = ValueNotifier<String?>(null);

  /// Placeholder [LeaderboardEntry.displayName] for the current user (localize in UI).
  static const String kLeaderboardYouMarker = '__L10N_YOU__';

  /// Placeholder when a friend has no row in `leaderboard/global` (localize in UI).
  static const String kLeaderboardMissingMarker = '__L10N_NOT_IN_BOARD__';

  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static Future<void> _ensureAuth() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      status.value = null;
    } catch (_) {}
  }

  static bool get _ready {
    try {
      return Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  static String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  /// Creates and stores a unique 6-char code if missing.
  /// Always returns a code: [ShareCodeLocal] when Firebase is off, not ready, or on error.
  static Future<String> ensureFriendCode() async {
    final String local = await ShareCodeLocal.getOrCreate();

    if (!kFirebaseOnlineFeaturesEnabled) {
      return local;
    }

    try {
      await _ensureAuth().timeout(_kOpTimeout);
      if (!_ready) {
        return local;
      }
      final String uid = _myUid!;
      final DatabaseReference mine = FirebaseDatabase.instance.ref('users/$uid/friendCode');
      final DataSnapshot existing = await mine.get().timeout(_kOpTimeout);
      if (existing.exists && existing.value is String) {
        final String s = (existing.value! as String).trim().toUpperCase();
        if (s.length == 6) {
          await ShareCodeLocal.save(s);
          return s;
        }
      }

      // Prefer registering the same code as on device (stable across reinstall if prefs kept).
      final DatabaseReference localRef = FirebaseDatabase.instance.ref('friendCodes/$local');
      final DataSnapshot taken = await localRef.get().timeout(_kOpTimeout);
      if (!taken.exists) {
        await localRef.set(<String, String>{'uid': uid}).timeout(_kOpTimeout);
        await mine.set(local).timeout(_kOpTimeout);
        await ShareCodeLocal.save(local);
        return local;
      }
      if (taken.value is Map) {
        final Map<Object?, Object?> m = taken.value! as Map<Object?, Object?>;
        final String? owner = m['uid'] as String?;
        if (owner == uid) {
          await mine.set(local).timeout(_kOpTimeout);
          await ShareCodeLocal.save(local);
          return local;
        }
      }

      final Random rnd = Random.secure();
      for (int attempt = 0; attempt < 40; attempt++) {
        final String code = List<String>.generate(
          6,
          (_) => _chars[rnd.nextInt(_chars.length)],
        ).join();
        final DatabaseReference codeRef = FirebaseDatabase.instance.ref('friendCodes/$code');
        final DataSnapshot snap = await codeRef.get().timeout(_kOpTimeout);
        if (snap.exists) {
          continue;
        }
        await codeRef.set(<String, String>{'uid': uid}).timeout(_kOpTimeout);
        await mine.set(code).timeout(_kOpTimeout);
        await ShareCodeLocal.save(code);
        return code;
      }
      return local;
    } catch (e) {
      status.value = 'FriendsService ensureFriendCode failed: $e';
      return local;
    }
  }

  /// Returns `null` on success.
  static Future<FriendAddError?> addFriendByCode(String raw) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return FriendAddError.firebaseDisabled;
    }
    await _ensureAuth().timeout(_kOpTimeout);
    if (!_ready) {
      return FriendAddError.notReady;
    }
    final String? myUid = _myUid;
    if (myUid == null) {
      return FriendAddError.noAccount;
    }
    final String code = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (code.length != 6) {
      return FriendAddError.invalidLength;
    }
    final DataSnapshot snap = await FirebaseDatabase.instance.ref('friendCodes/$code').get().timeout(_kOpTimeout);
    if (!snap.exists || snap.value is! Map) {
      return FriendAddError.notFound;
    }
    final Map<Object?, Object?> m = snap.value! as Map<Object?, Object?>;
    final String? friendUid = m['uid'] as String?;
    if (friendUid == null || friendUid.isEmpty) {
      return FriendAddError.badData;
    }
    if (friendUid == myUid) {
      return FriendAddError.ownCode;
    }
    await FirebaseDatabase.instance.ref('users/$myUid/friends/$friendUid').set(true).timeout(_kOpTimeout);
    return null;
  }

  static Future<String?> resolveUidByCode(String code) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return null;
    }
    await _ensureAuth();
    if (!_ready) {
      return null;
    }
    final DataSnapshot snap = await FirebaseDatabase.instance.ref('friendCodes/$code').get();
    if (!snap.exists || snap.value is! Map) {
      return null;
    }
    final Map<Object?, Object?> m = snap.value! as Map<Object?, Object?>;
    final String? uid = m['uid'] as String?;
    if (uid == null || uid.isEmpty) {
      return null;
    }
    return uid;
  }

  static Future<List<String>> listFriendUids() async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return <String>[];
    }
    await _ensureAuth().timeout(_kOpTimeout);
    if (!_ready) {
      return <String>[];
    }
    final String? myUid = _myUid;
    if (myUid == null) {
      return <String>[];
    }
    final DataSnapshot friendsSnap =
        await FirebaseDatabase.instance.ref('users/$myUid/friends').get().timeout(_kOpTimeout);
    final List<String> out = <String>[];
    if (friendsSnap.value is Map) {
      final Map<Object?, Object?> fm = friendsSnap.value! as Map<Object?, Object?>;
      fm.forEach((Object? k, Object? v) {
        if (v == true && k != null) {
          out.add(k.toString());
        }
      });
    }
    return out;
  }

  static Future<void> removeFriend(String friendUid) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return;
    }
    await _ensureAuth().timeout(_kOpTimeout);
    final String? myUid = _myUid;
    if (!_ready || myUid == null) {
      return;
    }
    await FirebaseDatabase.instance.ref('users/$myUid/friends/$friendUid').remove().timeout(_kOpTimeout);
  }

  /// Имя из `leaderboard/global` для экрана профиля.
  static Future<String> displayNameForUid(String uid) async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return uid;
    }
    await _ensureAuth().timeout(_kOpTimeout);
    if (!_ready) {
      return uid;
    }
    final DataSnapshot snap =
        await FirebaseDatabase.instance.ref('leaderboard/global/$uid').get().timeout(_kOpTimeout);
    if (!snap.exists || snap.value is! Map) {
      return uid;
    }
    final Map<Object?, Object?> m = snap.value! as Map<Object?, Object?>;
    final Object? dn = m['displayName'];
    if (dn is String && dn.trim().isNotEmpty) {
      return dn.trim();
    }
    return uid;
  }

  /// Sorted by score desc; includes self + friends with rows in `leaderboard/global`.
  static Future<List<LeaderboardEntry>> loadFriendsBoard() async {
    if (!kFirebaseOnlineFeaturesEnabled) {
      return LeaderboardService.loadLocalGlobalLeaderboard();
    }
    await _ensureAuth().timeout(_kOpTimeout);
    if (!_ready) {
      return <LeaderboardEntry>[];
    }
    final String? myUid = _myUid;
    if (myUid == null) {
      return <LeaderboardEntry>[];
    }
    final Set<String> uids = <String>{myUid};
    final DataSnapshot friendsSnap =
        await FirebaseDatabase.instance.ref('users/$myUid/friends').get().timeout(_kOpTimeout);
    if (friendsSnap.value is Map) {
      final Map<Object?, Object?> fm = friendsSnap.value! as Map<Object?, Object?>;
      fm.forEach((Object? k, Object? v) {
        if (v == true && k != null) {
          uids.add(k.toString());
        }
      });
    }

    final List<LeaderboardEntry> rows = <LeaderboardEntry>[];
    for (final String id in uids) {
      final DataSnapshot row =
          await FirebaseDatabase.instance.ref('leaderboard/global/$id').get().timeout(_kOpTimeout);
      if (row.exists && row.value is Map) {
        final Map<Object?, Object?> vm = Map<Object?, Object?>.from(row.value! as Map);
        rows.add(
          LeaderboardEntry.fromSnapshotMap(id, vm).copyWith(
            isMe: id == myUid,
          ),
        );
      } else {
        rows.add(
          LeaderboardEntry(
            uid: id,
            displayName: id == myUid ? kLeaderboardYouMarker : kLeaderboardMissingMarker,
            score: 0,
            bestCombo: 1,
            isMe: id == myUid,
          ),
        );
      }
    }
    rows.sort((LeaderboardEntry a, LeaderboardEntry b) => b.score.compareTo(a.score));
    return rows;
  }
}

enum FriendAddError {
  firebaseDisabled,
  notReady,
  noAccount,
  invalidLength,
  notFound,
  badData,
  ownCode,
}
