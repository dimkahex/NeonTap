import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists a 6-character share code on device (same alphabet as [FriendsService]).
/// Used when Firebase is off or not ready so the profile always shows a code to copy.
class ShareCodeLocal {
  ShareCodeLocal._();

  static const String _prefsKey = 'player_share_code_v1';
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static Future<String> getOrCreate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw != null && raw.length == 6) {
      return raw.toUpperCase();
    }
    final Random rnd = Random.secure();
    final String code = List<String>.generate(
      6,
      (_) => _chars[rnd.nextInt(_chars.length)],
    ).join();
    await prefs.setString(_prefsKey, code);
    return code;
  }

  static Future<void> save(String code) async {
    final String c = code.trim().toUpperCase();
    if (c.length != 6) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, c);
  }
}
