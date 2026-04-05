/// Shrinking-ring radius [r] at tap time. Smaller [r] = кольцо ближе к центру.
///
/// От центра наружу: центральная дыра → PERFECT (красный) → COOL → GOOD → OK → внешний MISS.
abstract final class TimingThresholds {
  TimingThresholds._();

  /// Центральная «чёрная точка»: [r] строго меньше — MISS.
  static const double rCenterMiss = 12;

  /// Внешняя граница красной зоны PERFECT (не включая): [r] в \[rCenterMiss, rPerfectOuter).
  static const double rPerfectOuter = 32;

  /// Внешняя граница жёлтой зоны COOL.
  static const double rCoolOuter = 52;

  /// Внешняя граница оранжевой зоны GOOD.
  static const double rGoodOuter = 72;

  /// Внутренняя граница зелёной зоны OK; [r] ≥ [rOkOuter] — внешний MISS (слишком рано).
  static const double rOkOuter = 140;
}
