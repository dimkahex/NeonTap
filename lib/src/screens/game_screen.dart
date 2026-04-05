import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../app_version.dart';
import '../game/difficulty.dart';
import '../game/judgement.dart';
import '../game/timing_thresholds.dart';
import '../game/run_result.dart';
import '../game/run_stats.dart';
import '../services/haptics.dart';
import '../services/leaderboard_service.dart';
import '../services/local_stats.dart';
import '../services/sfx.dart';
import '../services/challenge_service.dart';
import '../l10n_ext/hit_judgement_l10n.dart';
import '../ui/neon_background.dart';
import '../ui/neon_circle_painter.dart';
import '../ui/main_ring_hud_painter.dart';
import '../ui/static_score_rings_painter.dart';
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
  /// Visual guide only (shell lines); scoring uses main strip + single outer limit [_bandEdgeOuterPx].
  static const double _bandGrazeOuterPx = 52;
  static const double _bandRimOuterPx = 72;
  /// Outer edge of scoring band (|tap radius − ring|) beyond main strip — still OK if timing valid.
  static const double _bandEdgeOuterPx = 92;
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
  /// Consecutive PERFECTs already scored; next PERFECT uses ×2…×16 chain.
  int _perfectChain = 0;
  int _maxChainMultiplier = 1;

  int _hitsPerfect = 0;
  int _hitsCool = 0;
  int _hitsGood = 0;
  int _hitsOk = 0;

  String? _bigText;
  double _bigTextScale = 1;
  double _bigTextOpacity = 0;
  Timer? _bigTextTimer;

  bool _slowMo = false;
  Timer? _slowMoTimer;

  double _bonusScoreMul = 1.0;
  Timer? _bonusTimer;

  /// True while a tap is being scored — blocks [AnimationStatus.completed] from firing a spurious MISS
  /// (the shrink tween would otherwise finish during `await Sfx.playTap()` / judgement delays).
  bool _tapJudgementInProgress = false;

  @override
  void initState() {
    super.initState();
    final int firstMs = (difficultyForScore(0).shrinkSeconds * 1000).round();
    _shrink = AnimationController(vsync: this, duration: Duration(milliseconds: firstMs))
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
    _bonusTimer?.cancel();
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
    if (_tapJudgementInProgress) return;
    // If user didn't tap in time, treat as miss.
    unawaited(_handleJudgement(HitJudgement.miss));
  }

  double get _currentRadius {
    final double t = Curves.linear.transform(_shrink.value);
    return _maxRadius * (1 - t);
  }

  /// Next PERFECT tap uses ×2, ×4, ×8, or ×16 after consecutive PERFECTs.
  int get _nextPerfectMultiplier => 2 << _perfectChain.clamp(0, 3);

  void _restartCycle({required int scoreAfterTap}) {
    final Difficulty d = difficultyForScore(scoreAfterTap);
    final int ms = (d.shrinkSeconds * 1000).round();
    _shrink.duration = Duration(milliseconds: ms);
    _shrink.forward(from: 0);
  }

  HitJudgement _judge(double r) {
    if (r >= TimingThresholds.rOkOuter) return HitJudgement.miss;
    if (r < TimingThresholds.rCenterMiss) return HitJudgement.miss;
    if (r < TimingThresholds.rPerfectOuter) return HitJudgement.perfect;
    if (r < TimingThresholds.rCoolOuter) return HitJudgement.cool;
    if (r < TimingThresholds.rGoodOuter) return HitJudgement.good;
    return HitJudgement.ok;
  }

  Future<void> _handleTap(Offset tapPos, Size screenSize) async {
    // Sync first: freeze radius and block shrink-complete → MISS while async work runs.
    _tapJudgementInProgress = true;
    _shrink.stop();
    try {
      await Sfx.playTap();

      final Offset center = Offset(screenSize.width / 2, screenSize.height / 2) + _centerOffset.value;
      final double tapDist = (tapPos - center).distance;
      final double r = _currentRadius;

      final bool ringAim = _score >= _ringAimMinScore;
      if (ringAim) {
        final double delta = (tapDist - r).abs();
        if (delta > _bandEdgeOuterPx) {
          await _handleJudgement(HitJudgement.miss);
          return;
        }
        if (r > TimingThresholds.rCoolOuter && tapDist < _voidEyePx) {
          await _handleJudgement(HitJudgement.miss);
          return;
        }
        if (delta <= _ringHalfWidthPx) {
          await _handleJudgement(_judge(r));
          return;
        }
        final HitJudgement timing = _judge(r);
        if (timing == HitJudgement.miss) {
          await _handleJudgement(HitJudgement.miss);
          return;
        }
        await _handleJudgement(HitJudgement.ok);
        return;
      }

      await _handleJudgement(_judge(r));
    } finally {
      _tapJudgementInProgress = false;
    }
  }

  /// Random short score boost — procs on successful hits.
  void _maybeRollBonus() {
    if (_bonusScoreMul > 1.01) return;
    final double p = 0.035 + math.min(0.08, _score * 0.00012);
    if (math.Random().nextDouble() < p) {
      _bonusTimer?.cancel();
      if (!mounted) return;
      setState(() => _bonusScoreMul = 2.0);
      final int ms = 1000 + math.Random().nextInt(900);
      _bonusTimer = Timer(Duration(milliseconds: ms), () {
        if (mounted) setState(() => _bonusScoreMul = 1.0);
      });
    }
  }

  Future<void> _handleJudgement(HitJudgement j) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final int seed = DateTime.now().microsecondsSinceEpoch & 0x7fffffff;
    final double intensity = switch (j) {
      HitJudgement.perfect => 1.45,
      HitJudgement.cool => 1.12,
      HitJudgement.good => 1.08,
      HitJudgement.ok => 0.95,
      HitJudgement.miss => 0.95,
    };
    emitParticleEvent(_particleEvents, j, seed, intensity: intensity);

    await Future.wait(<Future<void>>[
      Haptics.forJudgement(j),
      if (j != HitJudgement.miss) Sfx.playHit(j) else Sfx.playDefeat(),
    ]);

    if (!mounted) return;

    if (j != HitJudgement.miss) {
      _missFlash.reset();
    }

    switch (j) {
      case HitJudgement.perfect:
        _hitsPerfect++;
        final int mult = 2 << _perfectChain.clamp(0, 3);
        _maxChainMultiplier = math.max(_maxChainMultiplier, mult);
        final int add = (j.basePoints * mult * _bonusScoreMul).round();
        _perfectChain++;
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.locLabel(l10n), scale: 1.14, glow: true);
        _slowMoFor(const Duration(seconds: 5));
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() => _score += add);
        _maybeRollBonus();
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.cool:
        _hitsCool++;
        _perfectChain = 0;
        final int add = (j.basePoints * _bonusScoreMul).round();
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.locLabel(l10n), scale: 1.08, glow: false);
        await Future<void>.delayed(const Duration(milliseconds: 110));
        if (!mounted) return;
        setState(() => _score += add);
        _maybeRollBonus();
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.good:
        _hitsGood++;
        _perfectChain = 0;
        final int add = (j.basePoints * _bonusScoreMul).round();
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.locLabel(l10n), scale: 1.06, glow: false);
        await Future<void>.delayed(const Duration(milliseconds: 110));
        if (!mounted) return;
        setState(() => _score += add);
        _maybeRollBonus();
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.ok:
        _hitsOk++;
        _perfectChain = 0;
        final int add = (j.basePoints * _bonusScoreMul).round();
        emitFloatingPoints(_floatingPoints, value: add, j: j, seed: seed);
        _hitPulse.forward(from: 0);
        _showBigText(j.locLabel(l10n), scale: 1.02, glow: false);
        await Future<void>.delayed(const Duration(milliseconds: 110));
        if (!mounted) return;
        setState(() => _score += add);
        _maybeRollBonus();
        _restartCycle(scoreAfterTap: _score);
        return;
      case HitJudgement.miss:
        _perfectChain = 0;
        _showBigText(j.locLabel(l10n), scale: 1.0, glow: false);
        _missFlash.forward(from: 0);
        await Future<void>.delayed(const Duration(milliseconds: 180));
        if (!mounted) return;
        await _exitToResults();
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

  Future<void> _exitToResults() async {
    _shrink.stop();
    final int bestCombo = _maxChainMultiplier;

    final (int bestScore, int bestComboStored, bool newBest) =
        await LocalStats.updateBestIfNeeded(score: _score, bestCombo: bestCombo);

    unawaited(
      LeaderboardService.syncBestFromLocal(
        bestScore: bestScore,
        bestCombo: bestComboStored,
      ),
    );
    unawaited(
      ChallengeService.submitRun(
        score: _score,
        bestCombo: bestCombo,
      ),
    );

    final int lifetimeRun = await LocalStats.incrementTotalRuns();

    // Placeholder "global rank": higher score => lower number.
    final int rankEstimate = (120000 / math.max(1, _score + 12)).round().clamp(1, 99999);

    final JudgementBreakdown breakdown = JudgementBreakdown(
      perfect: _hitsPerfect,
      cool: _hitsCool,
      good: _hitsGood,
      ok: _hitsOk,
    );

    final RunResult result = RunResult(
      score: _score,
      bestCombo: bestCombo,
      isNewBestScore: newBest,
      bestScore: bestScore,
      rankEstimate: rankEstimate,
      breakdown: breakdown,
      lifetimeRunIndex: lifetimeRun,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ResultsScreen.route, arguments: result);
  }

  /// Spiral visible from the first frame; intensity ramps with score (capped so it does not drown the playfield).
  double _spiralIntensityForScore(int s) {
    if (s < 40) return 0.16;
    if (s < 120) return 0.28;
    if (s < 250) return 0.40;
    if (s < 400) return 0.52;
    return 0.64;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Difficulty d = difficultyForScore(_score);
    final bool distract = d.pulseDistract;
    final bool ringAim = _score >= _ringAimMinScore;
    final double spiralIntensity =
        _spiralIntensityForScore(_score) * (ringAim ? 0.64 : 1.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _exitToResults();
      },
      child: Scaffold(
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
                    return CustomPaint(
                      painter: NeonCirclePainter(
                        radius: rr,
                        maxRadius: _maxRadius,
                        pulse: distract ? _pulse.value : 0,
                        missFlash: _missFlash.value,
                        centerOffset: _centerOffset.value,
                        hideMainRingStroke: true,
                      ),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
              Positioned.fill(child: ParticlesOverlay(events: _particleEvents)),
              Positioned.fill(child: FloatingPointsOverlay(events: _floatingPoints, centerOffset: _centerOffset)),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: Listenable.merge(<Listenable>[_shrink, _centerOffset]),
                    builder: (BuildContext context, _) {
                      final double r = _currentRadius;
                      return Stack(
                        children: <Widget>[
                          CustomPaint(
                            painter: StaticScoreRingsPainter(
                              centerOffset: _centerOffset.value,
                            ),
                            child: const SizedBox.expand(),
                          ),
                          CustomPaint(
                            painter: MainRingHudPainter(
                              radius: r,
                              maxRadius: _maxRadius,
                              centerOffset: _centerOffset.value,
                            ),
                            child: const SizedBox.expand(),
                          ),
                          if (ringAim)
                            CustomPaint(
                              painter: RingGuidePainter(
                                centerOffset: _centerOffset.value,
                                ringRadius: r,
                                halfWidth: _ringHalfWidthPx,
                                bandGrazeOuter: _bandGrazeOuterPx,
                                bandRimOuter: _bandRimOuterPx,
                                bandEdgeOuter: _bandEdgeOuterPx,
                                opacity: 0.48,
                              ),
                              child: const SizedBox.expand(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  tooltip: l10n.gameEndRunTooltip,
                  onPressed: () => unawaited(_exitToResults()),
                ),
              ),
              Positioned(
                top: 14,
                left: 56,
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
                      ringAim ? l10n.gameAimHint : l10n.gameWarmupHint,
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
                    Row(
                      children: <Widget>[
                        Text(
                          'x$_nextPerfectMultiplier',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                        ),
                        if (_bonusScoreMul > 1.01) ...<Widget>[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
                              color: const Color(0x22FFE082),
                            ),
                            child: Text(
                              l10n.gameScoreX2,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFFFE082),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      l10n.gameStage(d.stage, d.shrinkSeconds.toStringAsFixed(2)),
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
    ),
    );
  }
}

class _RankRisingBadge extends StatelessWidget {
  const _RankRisingBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
        l10n.gameRankRising,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
      ),
    );
  }
}

