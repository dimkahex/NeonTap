import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../locale/app_locale_scope.dart';
import '../locale/locale_controller.dart';
import '../services/settings_prefs.dart';
import '../services/sfx.dart';
import '../ui/neon_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String route = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _soundEnabled = true;
  int _volumePercent = 100;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final bool on = await SettingsPrefs.getSoundEnabled();
    final int v = await SettingsPrefs.getVolumePercent();
    if (!mounted) {
      return;
    }
    setState(() {
      _soundEnabled = on;
      _volumePercent = v;
      _loading = false;
    });
  }

  Future<void> _setSoundEnabled(bool value) async {
    setState(() => _soundEnabled = value);
    await SettingsPrefs.setSoundEnabled(value);
    await Sfx.reloadFromPrefs();
  }

  Future<void> _setVolumePercent(int value) async {
    setState(() => _volumePercent = value);
    await SettingsPrefs.setVolumePercent(value);
    await Sfx.reloadFromPrefs();
  }

  Future<void> _showLanguageDialog(AppLocalizations l10n, LocaleController locale) async {
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.settingsLanguagePickerTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<String>(
                title: Text(l10n.profileLanguageRu),
                value: 'ru',
                groupValue: locale.locale.languageCode,
                onChanged: (String? v) => Navigator.of(ctx).pop(v),
              ),
              RadioListTile<String>(
                title: Text(l10n.profileLanguageEn),
                value: 'en',
                groupValue: locale.locale.languageCode,
                onChanged: (String? v) => Navigator.of(ctx).pop(v),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) {
      await locale.setLanguageCode(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LocaleController locale = AppLocaleScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: NeonBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: <Widget>[
                  Text(
                    l10n.settingsAudioSection,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(l10n.settingsSoundEnabled),
                    value: _soundEnabled,
                    onChanged: (bool v) => unawaited(_setSoundEnabled(v)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.settingsVolume,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Slider(
                          value: _volumePercent.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: '$_volumePercent%',
                          onChanged: _soundEnabled
                              ? (double x) => unawaited(_setVolumePercent(x.round()))
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '$_volumePercent%',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.settingsLanguage,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      locale.locale.languageCode == 'ru' ? l10n.profileLanguageRu : l10n.profileLanguageEn,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                    onTap: () => unawaited(_showLanguageDialog(l10n, locale)),
                  ),
                ],
              ),
      ),
    );
  }
}
