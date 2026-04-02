import 'package:audioplayers/audioplayers.dart';

import '../game/judgement.dart';

class Sfx {
  Sfx._();

  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Assets are optional in Phase 1. We try to play them if present;
  // missing assets shouldn't crash the run.
  static Future<void> playJudgement(HitJudgement j) async {
    final String asset = switch (j) {
      HitJudgement.ultra => 'sfx/ultra_bass.wav',
      HitJudgement.perfect => 'sfx/perfect_hit.wav',
      HitJudgement.good => 'sfx/good_tick.wav',
      HitJudgement.miss => 'sfx/miss_error.wav',
    };
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {
      // ignore (assets not added yet)
    }
  }

  static Future<void> playLoopWhoosh() async {
    try {
      await _player.play(AssetSource('sfx/whoosh_loop.wav'));
    } catch (_) {
      // ignore
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {
      // ignore
    }
  }
}

