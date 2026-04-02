import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/difficulty.dart';
import '../game/judgement.dart';
import '../game/run_result.dart';
import '../services/haptics.dart';
import '../services/local_stats.dart';
import '../services/sfx.dart';
import '../ui/neon_background.dart';
import '../ui/neon_circle_painter.dart';
import '../ui/particles_overlay.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const String route = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const double _maxRadius = 270;

  late AnimationController _shrink;
  late AnimationController _pulse;
  late AnimationController _missFlash;

  final ValueNotifier<ParticleEvent?> _particleEvents = particleEventsNotifier();

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
  }

  @override
  void dispose() {
    _bigTextTimer?.cancel();
    _slowMoTimer?.cancel();
    _shrink.dispose();
    _pulse.dispose();
    _missFlash.dispose();
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
    return HitJudgement.miss;
  }

  Future<void> _handleTap() async {
    final double r = _currentRadius;
    final HitJudgement j = _judge(r);
    await _handleJudgement(j);
  }

  Future<void> _handleJudgement(HitJudgement j) async {
    final int seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    emitParticleEvent(_particleEvents, j, seed);

    await Future.wait(<Future<void>>[
      Haptics.forJudgement(j),
      Sfx.playJudgement(j),
    ]);

    if (!mounted) return;

    switch (j) {
      case HitJudgement.ultra:
        _comboPow = (_comboPow + 1).clamp(0, 4);
        _bestComboPow = math.max(_bestComboPow, _comboPow);
        final int add = j.basePoints * _comboMultiplier;
        setState(() {
          _score += add;
        });
        _showBigText(j.label, scale: 1.14, glow: true);
        _slowMoFor(const Duration(seconds: 5));
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.perfect:
      case HitJudgement.good:
        _comboPow = (_comboPow + 1).clamp(0, 4);
        _bestComboPow = math.max(_bestComboPow, _comboPow);
        final int add = j.basePoints * _comboMultiplier;
        setState(() {
          _score += add;
        });
        _showBigText(j.label, scale: 1.06, glow: false);
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

  @override
  Widget build(BuildContext context) {
    final Difficulty d = difficultyForScore(_score);
    final bool distract = d.pulseDistract;

    return Scaffold(
      body: NeonBackground(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => unawaited(_handleTap()),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge(<Listenable>[_shrink, _pulse, _missFlash]),
                  builder: (BuildContext context, _) {
                    final double r = _currentRadius;
                    return CustomPaint(
                      painter: NeonCirclePainter(
                        radius: r,
                        maxRadius: _maxRadius,
                        pulse: distract ? _pulse.value : 0,
                        missFlash: _missFlash.value,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
              Positioned.fill(child: ParticlesOverlay(events: _particleEvents)),
              Positioned(
                top: 14,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _score.toString(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                    ),
                    _RankRisingBadge(score: _score),
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
                                Shadow(color: Color(0x8835E6FF), blurRadius: 24),
                                Shadow(color: Color(0x66FF2ED1), blurRadius: 28),
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

