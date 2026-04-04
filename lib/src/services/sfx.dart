import 'package:audioplayers/audioplayers.dart';

import '../game/judgement.dart';
import 'settings_prefs.dart';

class Sfx {
  Sfx._();

  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _tapPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);

  static bool _soundEnabled = true;
  static double _volume01 = 1.0;

  /// `true` after [AssetSource] for BGM was prepared (buffered once).
  static bool _bgmPrepared = false;

  /// BGM keeps long-form focus; SFX use transient ducking so music is not stopped (Android audio focus).
  static const AudioContext _ctxBgm = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: <AVAudioSessionOptions>{AVAudioSessionOptions.mixWithOthers},
    ),
  );

  /// Short taps + one-shot hits: do not take exclusive focus from BGM.
  static const AudioContext _ctxSfx = AudioContext(
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: <AVAudioSessionOptions>{AVAudioSessionOptions.mixWithOthers},
    ),
  );

  /// Call once after [WidgetsFlutterBinding.ensureInitialized].
  /// Hit/perfect SFX use [PlayerMode.mediaPlayer] — low-latency pool can drop longer samples like `perfect_hit.wav`.
  static Future<void> initAudio() async {
    try {
      await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _musicPlayer.setAudioContext(_ctxBgm);

      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setAudioContext(_ctxSfx);

      await _tapPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _tapPlayer.setAudioContext(_ctxSfx);
    } catch (_) {}
  }

  /// Call from [main] and after changing sound settings.
  /// [allowStartBgm] — `false` at cold start so music does not play during splash; main menu calls [startBackgroundMusic].
  static Future<void> reloadFromPrefs({bool allowStartBgm = true}) async {
    _soundEnabled = await SettingsPrefs.getSoundEnabled();
    final int p = await SettingsPrefs.getVolumePercent();
    _volume01 = (p / 100.0).clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume01);
      await _tapPlayer.setVolume(_volume01);
      await _musicPlayer.setVolume(_volume01);
    } catch (_) {}

    if (!_soundEnabled) {
      try {
        await _musicPlayer.pause();
      } catch (_) {}
    } else if (allowStartBgm) {
      await startBackgroundMusic();
    }
  }

  /// Looping BGM: first [play] loads/buffers the track once; later only [resume] after pause (settings / mute).
  static Future<void> startBackgroundMusic() async {
    if (!_soundEnabled) {
      return;
    }
    try {
      if (!_bgmPrepared) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.setVolume(_volume01);
        await _musicPlayer.play(AssetSource('music/fon.mp3'));
        _bgmPrepared = true;
        return;
      }

      final PlayerState st = _musicPlayer.state;
      if (st == PlayerState.playing) {
        await _musicPlayer.setVolume(_volume01);
        return;
      }
      await _musicPlayer.setVolume(_volume01);
      await _musicPlayer.resume();
    } catch (_) {}
  }

  /// Short feedback on every tap (does not block hit/miss sounds).
  static Future<void> playTap() async {
    if (!_soundEnabled) {
      return;
    }
    try {
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
      await _player.play(AssetSource('sfx/defeat.wav'));
    } catch (_) {
      try {
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
      await _player.play(AssetSource('sfx/whoosh_loop.wav'));
    } catch (_) {
      // ignore
    }
  }

  /// Stops one-shot SFX players (not background music).
  static Future<void> stop() async {
    try {
      await _player.stop();
      await _tapPlayer.stop();
    } catch (_) {
      // ignore
    }
  }
}
