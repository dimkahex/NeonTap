import 'dart:math' as math;

/// Сложность: плавное сжатие окна по счёту, ступени для UI/эффектов без рывков.
class Difficulty {
  const Difficulty({
    required this.shrinkSeconds,
    required this.comboMaxPow,
    required this.pulseDistract,
    required this.stage,
  });

  /// Время полного цикла сужения (больше = проще).
  final double shrinkSeconds;
  final int comboMaxPow;
  final bool pulseDistract;
  /// 1..14 — волна для подписи этапа и эффектов.
  final int stage;
}

/// Плавная кривая без «ступенек» между чекпоинтами: экспонента + мягкий добой вглубь игры.
double _shrinkSecondsForScore(int score) {
  const double floor = 0.72;
  const double start = 4.52;
  final double x = score.toDouble().clamp(0, 500000.0);
  // Основной мягкий спад: долго остаёмся в «комфортной» зоне, затем плавно ускоряемся.
  double s = floor + (start - floor) * math.exp(-x / 940.0);
  // Доп. поджим после ~мидгейма, без резкого излома.
  if (x > 1280) {
    final double w = (x - 1280) / 4500.0;
    s = floor + (s - floor) * math.exp(-w * 1.08);
  }
  return s.clamp(floor, 5.8);
}

/// Ступени «волны» — чаще в начале (каждые ~50–90 очков ощущение смены), плавнее чем старые жёсткие пороги.
int _stageForScore(int score) {
  if (score <= 0) return 1;
  final int s = 1 + (math.sqrt(score / 32.0)).floor();
  return s.clamp(1, 14);
}

int _comboMaxPowForStage(int stage) {
  if (stage <= 3) return 2;
  if (stage <= 7) return 3;
  return 4;
}

bool _pulseDistractFor(int score, int stage) {
  return score >= 320 || stage >= 8;
}

Difficulty difficultyForScore(int score) {
  final int stage = _stageForScore(score);
  return Difficulty(
    shrinkSeconds: _shrinkSecondsForScore(score),
    comboMaxPow: _comboMaxPowForStage(stage),
    pulseDistract: _pulseDistractFor(score, stage),
    stage: stage,
  );
}
