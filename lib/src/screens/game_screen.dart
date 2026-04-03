import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_version.dart';
import '../game/difficulty.dart';
import '../game/judgement.dart';
import '../game/run_result.dart';
import '../services/haptics.dart';
import '../services/local_stats.dart';
import '../services/sfx.dart';
import '../ui/neon_background.dart';
import '../ui/neon_circle_painter.dart';
import '../ui/floating_points_overlay.dart';
import '../ui/particles_overlay.dart';
import '../ui/ring_guide_painter.dart';
import '../ui/spiral_overlay.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const String route = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const double _maxRadius = 270;
  /// Half-width of the "ring" band — tap must land on the shrinking circle (not random screen tap).
  static const double _ringHalfWidthPx = 30;
  /// Decorative spiral "eye" — if the ring is far out, tapping the eye is a miss.
  static const double _voidEyePx = 16;
  /// Ring aim + spiral visible early (was 150 — too long to notice in a short run).
  static const int _ringAimMinScore = 35;
  static const int _driftMinScore = 70;

  late AnimationController _shrink;
  late AnimationController _pulse;
  late AnimationController _missFlash;
  late AnimationController _hitPulse;
  late AnimationController _drift;

  final ValueNotifier<ParticleEvent?> _particleEvents = particleEventsNotifier();
  final ValueNotifier<FloatingPointsEvent?> _floatingPoints = floatingPointsNotifier();
  final ValueNotifier<Offset> _centerOffset = ValueNotifier<Offset>(Offset.zero);

  int _score = 0;
  int _comboPow = 0; // 0..4 => x1..x16
  int _bestComboPow = 0;

  String? _bigText;
  double _bigTextScale = 1;
  double _bigTextOpacity = 0;
  Timer? _bigTextTimer;

  bool _slowMo = false;
  Timer? _slowMoTimer;

  @override
  void initState() {
    super.initState();
    _shrink = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..addStatusListener(_onShrinkStatus)
      ..forward();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
    _missFlash = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _hitPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _drift = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..addListener(_updateDrift)
      ..repeat();
  }

  @override
  void dispose() {
    _bigTextTimer?.cancel();
    _slowMoTimer?.cancel();
    _shrink.dispose();
    _pulse.dispose();
    _missFlash.dispose();
    _hitPulse.dispose();
    _drift.dispose();
    _centerOffset.dispose();
    Sfx.stop();
    super.dispose();
  }

  void _onShrinkStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    // If user didn't tap in time, treat as miss.
    unawaited(_handleJudgement(HitJudgement.miss));
  }

  double get _currentRadius {
    final double t = Curves.linear.transform(_shrink.value);
    return _maxRadius * (1 - t);
  }

  int get _comboMultiplier => 1 << _comboPow;

  void _restartCycle({required int scoreAfterTap}) {
    final Difficulty d = difficultyForScore(scoreAfterTap);
    final int ms = (d.shrinkSeconds * 1000).round();
    _shrink.duration = Duration(milliseconds: ms);
    _shrink.forward(from: 0);
  }

  HitJudgement _judge(double r) {
    if (r < 15) return HitJudgement.ultra;
    if (r < 30) return HitJudgement.perfect;
    if (r < 70) return HitJudgement.good;
    if (r < 110) return HitJudgement.ok;
    return HitJudgement.miss;
  }

  Future<void> _handleTap(Offset tapPos, Size screenSize) async {
    await Sfx.playTap();

    final Offset center = Offset(screenSize.width / 2, screenSize.height / 2) + _centerOffset.value;
    final double tapDist = (tapPos - center).distance;
    final double r = _currentRadius;

    // Ring aim: tap must land on the current ring (not anywhere on screen).
    final bool ringAim = _score >= _ringAimMinScore;
    if (ringAim) {
      final double delta = (tapDist - r).abs();
      if (delta > _ringHalfWidthPx) {
        await _handleJudgement(HitJudgement.miss);
        return;
      }
      // Spiral eye: if ring is far from center, tapping the empty middle is not a hit.
      if (r > 52 && tapDist < _voidEyePx) {
        await _handleJudgement(HitJudgement.miss);
        return;
      }
    }

    final HitJudgement j = _judge(r);
    await _handleJudgement(j);
  }

  Future<void> _handleJudgement(HitJudgement j) async {
    final int seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    final double intensity = switch (j) {
      HitJudgement.ultra => 1.55,
      HitJudgement.perfect => 1.25,
      HitJudgement.good => 1.05,
      HitJudgement.ok => 0.9,
      HitJudgement.miss => 0.95,
    };
    emitParticleEvent(_particleEvents, j, seed, intensity: intensity);

    await Future.wait(<Future<void>>[
      Haptics.forJudgement(j),
      if (j != HitJudgement.miss) Sfx.playHit(j) else Sfx.playDefeat(),
    ]);

    if (!mounted) return;

    switch (j) {
      case HitJudgement.ultra:
        _comboPow = (_comboPow + 1).clamp(0, 4);
        _bestComboPow = math.max(_bestComboPow, _comboPow);
        final int add = j.basePoints * _comboMultiplier;
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.label, scale: 1.16, glow: true);
        _slowMoFor(const Duration(seconds: 5));
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() => _score += add);
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.perfect:
      case HitJudgement.good:
      case HitJudgement.ok:
        _comboPow = (_comboPow + 1).clamp(0, 4);
        _bestComboPow = math.max(_bestComboPow, _comboPow);
        final int add = j.basePoints * _comboMultiplier;
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.label, scale: j == HitJudgement.ok ? 1.02 : 1.08, glow: j == HitJudgement.perfect);
        await Future<void>.delayed(const Duration(milliseconds: 110));
        if (!mounted) return;
        setState(() => _score += add);
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.miss:
        _comboPow = 0;
        _showBigText(j.label, scale: 1.0, glow: false);
        _missFlash.forward(from: 0);
        await Future<void>.delayed(const Duration(milliseconds: 180));
        if (!mounted) return;
        await _finishRun();
        return;
    }
  }

  void _updateDrift() {
    if (_score < _driftMinScore) {
      if (_centerOffset.value != Offset.zero) _centerOffset.value = Offset.zero;
      return;
    }
    final double t = _drift.value * math.pi * 2;
    final double amp = (_score >= 400 ? 18.0 : 10.0);
    _centerOffset.value = Offset(math.sin(t * 0.9) * amp, math.cos(t * 1.1) * (amp * 0.7));
  }

  void _slowMoFor(Duration d) {
    if (_slowMo) return;
    _slowMo = true;
    _slowMoTimer?.cancel();

    // Slow down current cycle by stretching remaining time.
    final double v = _shrink.value;
    final Duration? base = _shrink.duration;
    if (base != null) {
      final int remainingMs = ((1 - v) * base.inMilliseconds).round();
      _shrink.duration = Duration(milliseconds: (remainingMs * 1.65).round().clamp(200, 9000));
      _shrink.forward(from: v);
    }

    _slowMoTimer = Timer(d, () {
      _slowMo = false;
    });
  }

  void _showBigText(String text, {required double scale, required bool glow}) {
    _bigTextTimer?.cancel();
    setState(() {
      _bigText = text;
      _bigTextScale = scale;
      _bigTextOpacity = 1;
    });
    _bigTextTimer = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _bigTextOpacity = 0;
        _bigTextScale = scale + 0.06;
      });
    });
  }

  Future<void> _finishRun() async {
    _shrink.stop();
    final int bestCombo = 1 << _bestComboPow;

    final (int bestScore, int bestComboStored, bool newBest) =
        await LocalStats.updateBestIfNeeded(score: _score, bestCombo: bestCombo);

    // Placeholder "global rank": higher score => lower number.
    final int rankEstimate = (120000 / math.max(1, _score + 12)).round().clamp(1, 99999);

    final RunResult result = RunResult(
      score: _score,
      bestCombo: bestCombo,
      isNewBestScore: newBest,
      bestScore: bestScore,
      rankEstimate: rankEstimate,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ResultsScreen.route, arguments: result);
  }

  /// Spiral visible from the first frame; intensity ramps with score.
  double _spiralIntensityForScore(int s) {
    if (s < 40) return 0.20;
    if (s < 120) return 0.38;
    if (s < 250) return 0.55;
    if (s < 400) return 0.78;
    return 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final Difficulty d = difficultyForScore(_score);
    final bool distract = d.pulseDistract;
    final double spiralIntensity = _spiralIntensityForScore(_score);
    final bool ringAim = _score >= _ringAimMinScore;

    return Scaffold(
      body: NeonBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) =>
              unawaited(_handleTap(details.localPosition, MediaQuery.sizeOf(context))),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: SpiralOverlay(
                  centerOffset: _centerOffset,
                  enabled: true,
                  intensity: spiralIntensity,
                  score: _score,
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge(<Listenable>[_shrink, _pulse, _missFlash, _hitPulse, _centerOffset]),
                  builder: (BuildContext context, _) {
                    final double r = _currentRadius;
                    final double hitScale = 1.0 + (0.035 * (1.0 - Curves.easeOut.transform(_hitPulse.value)));
                    final double rr = r * hitScale;
                    return Stack(
                      children: <Widget>[
                        if (ringAim)
                          CustomPaint(
                            painter: RingGuidePainter(
                              centerOffset: _centerOffset.value,
                              ringRadius: rr,
                              halfWidth: _ringHalfWidthPx,
                              opacity: 1.0,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        CustomPaint(
                          painter: NeonCirclePainter(
                            radius: rr,
                            maxRadius: _maxRadius,
                            pulse: distract ? _pulse.value : 0,
                            missFlash: _missFlash.value,
                            centerOffset: _centerOffset.value,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Positioned.fill(child: ParticlesOverlay(events: _particleEvents)),
              Positioned.fill(child: FloatingPointsOverlay(events: _floatingPoints, centerOffset: _centerOffset)),
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _score.toString(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              kAppVersion,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white38,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            _RankRisingBadge(score: _score),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ringAim
                          ? 'AIM: tap on the ring (not empty space)'
                          : 'Warm-up — ring aim starts soon',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: ringAim ? const Color(0xFF35E6FF) : Colors.white54,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'x$_comboMultiplier',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                    ),
                    Text(
                      '${d.shrinkSeconds.toStringAsFixed(2)}s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 0.6,
                          ),
                    ),
                  ],
                ),
              ),
              if (_bigText != null)
                Center(
                  child: AnimatedOpacity(
                    opacity: _bigTextOpacity,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: _bigTextScale,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: Text(
                        _bigText!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.8,
                              shadows: const <Shadow>[
                                Shadow(color: Color(0xAA35E6FF), blurRadius: 28),
                                Shadow(color: Color(0x88FF2ED1), blurRadius: 34),
                              ],
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankRisingBadge extends StatelessWidget {
  const _RankRisingBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final bool show = score == 50 || score == 150 || score == 400;
    if (!show) return const SizedBox(width: 0, height: 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF35E6FF), width: 1.2),
        color: Colors.black.withOpacity(0.25),
      ),
      child: Text(
        'RANK RISING!',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
      ),
    );
  }
}

