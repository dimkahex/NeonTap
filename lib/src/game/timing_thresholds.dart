/// Single source of truth for timing tiers: judgement uses **current shrink radius** [r].
/// PERFECT ⇔ ring has shrunk **inside** the circle of radius [rPerfect] (i.e. r < rPerfect).
abstract final class TimingThresholds {
  TimingThresholds._();

  static const double rPerfect = 36;
  static const double rGood = 54;
  static const double rOkOuter = 140;
}
