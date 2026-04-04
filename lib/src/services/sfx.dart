import 'package:audioplayers/audioplayers.dart';

import '../game/judgement.dart';
import 'settings_prefs.dart';

class Sfx {
  Sfx._();

  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _tapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static bool _soundEnabled = true;
  static double _volume01 = 1.0;

  /// Call from [main] and after changing sound settings.
  static Future<void> reloadFromPrefs() async {
    _soundEnabled = await SettingsPrefs.getSoundEnabled();
    final int p = await SettingsPrefs.getVolumePercent();
    _volume01 = (p / 100.0).clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume01);
      await _tapPlayer.setVolume(_volume01);
    } catch (_) {}
  }

  static Future<void> _applyVolume() async {
    try {
      await _player.setVolume(_volume01);
      await _tapPlayer.setVolume(_volume01);
    } catch (_) {}
  }

  /// Short feedback on every tap (does not block hit/miss sounds).
  static Future<void> playTap() async {
    if (!_soundEnabled) {
      return;
    }
    try {
      await _applyVolume();
      await _tapPlayer.play(AssetSource('sfx/tap_soft.wav'));
    } catch (_) {
      // ignore (optional asset)
    }
  }

  /// After a successful hit (good/ok/perfect/ultra).
  static Future<void> playHit(HitJudgement j) async {
    if (!_soundEnabled) {
      return;
    }
    final String asset = switch (j) {
      // User request: best hit uses "perfect" SFX.
      HitJudgement.ultra => 'sfx/perfect_hit.wav',
      HitJudgement.perfect => 'sfx/perfect_hit.wav',
      HitJudgement.good => 'sfx/good_tick.wav',
      HitJudgement.ok => 'sfx/ok_click.wav',
      HitJudgement.graze => 'sfx/ok_click.wav',
      HitJudgement.rim => 'sfx/ok_click.wav',
      HitJudgement.edge => 'sfx/ok_click.wav',
      HitJudgement.miss => 'sfx/miss_error.wav',
    };
    try {
      await _applyVolume();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // ignore
    }
  }

  /// Legacy: full judgement (tap + hit combined flow uses playTap + playHit).
  static Future<void> playJudgement(HitJudgement j) async => playHit(j);

  /// Run over / loss.
  static Future<void> playDefeat() async {
    if (!_soundEnabled) {
      return;
    }
    try {
      await _applyVolume();
      await _player.play(AssetSource('sfx/defeat.wav'));
    } catch (_) {
      try {
        await _applyVolume();
        await _player.play(AssetSource('sfx/miss_error.wav'));
      } catch (_) {
        // ignore
      }
    }
  }

  static Future<void> playLoopWhoosh() async {
    if (!_soundEnabled) {
      return;
    }
    try {
      await _applyVolume();
      await _player.play(AssetSource('sfx/whoosh_loop.wav'));
    } catch (_) {
      // ignore
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      await _tapPlayer.stop();
    } catch (_) {
      // ignore
    }
  }
}
