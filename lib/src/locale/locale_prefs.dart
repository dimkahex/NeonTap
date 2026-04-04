import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleCode = 'app_locale_code';

/// Persisted UI language: `ru` (default) or `en`.
class LocalePrefs {
  LocalePrefs._();

  static Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? v = prefs.getString(_kLocaleCode);
    if (v == 'en') {
      return 'en';
    }
    if (v == 'ru') {
      return 'ru';
    }
    return 'ru';
  }

  static Future<void> setLanguageCode(String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (code == 'en' || code == 'ru') {
      await prefs.setString(_kLocaleCode, code);
    }
  }
}
