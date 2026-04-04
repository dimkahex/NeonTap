import 'package:flutter/material.dart';

import 'locale_prefs.dart';

/// Drives [MaterialApp.locale]; default Russian until [load] completes.
class LocaleController extends ChangeNotifier {
  LocaleController() : _locale = const Locale('ru');

  Locale _locale;

  Locale get locale => _locale;

  Future<void> load() async {
    final String code = await LocalePrefs.getLanguageCode();
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    if (code != 'en' && code != 'ru') {
      return;
    }
    _locale = Locale(code);
    await LocalePrefs.setLanguageCode(code);
    notifyListeners();
  }
}
