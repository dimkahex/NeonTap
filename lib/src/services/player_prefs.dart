import 'package:shared_preferences/shared_preferences.dart';

class PlayerPrefs {
  static const String _kDisplayName = 'player_display_name';

  static Future<String> getDisplayName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDisplayName)?.trim().isNotEmpty == true
        ? prefs.getString(_kDisplayName)!.trim()
        : 'Player';
  }

  static Future<void> setDisplayName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String t = name.trim();
    await prefs.setString(_kDisplayName, t.isEmpty ? 'Player' : t);
  }
}
