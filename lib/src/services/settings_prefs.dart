import 'package:shared_preferences/shared_preferences.dart';

/// Sound toggle and master volume (SFX). UI language is in [locale_prefs.dart].
class SettingsPrefs {
  SettingsPrefs._();

  static const String _kSoundEnabled = 'settings_sound_enabled';
  static const String _kVolumePercent = 'settings_volume_percent';

  static Future<bool> getSoundEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEnabled, value);
  }

  /// 0–100, default 100.
  static Future<int> getVolumePercent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? v = prefs.getInt(_kVolumePercent);
    if (v == null) {
      return 100;
    }
    return v.clamp(0, 100);
  }

  static Future<void> setVolumePercent(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kVolumePercent, value.clamp(0, 100));
  }
}
