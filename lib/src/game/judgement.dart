enum HitJudgement {
  /// Wide outer band — minimal points (easier aim).
  graze,
  ok,
  ultra,
  perfect,
  good,
  miss,
}

extension HitJudgementUi on HitJudgement {
  String get label => switch (this) {
        HitJudgement.graze => 'GRAZE',
        HitJudgement.ok => 'OK',
        HitJudgement.ultra => 'ULTRA',
        HitJudgement.perfect => 'PERFECT',
        HitJudgement.good => 'GOOD',
        HitJudgement.miss => 'MISS',
      };

  int get basePoints => switch (this) {
        HitJudgement.graze => 1,
        HitJudgement.ok => 2,
        HitJudgement.ultra => 10,
        HitJudgement.perfect => 5,
        HitJudgement.good => 2,
        HitJudgement.miss => 0,
      };
}

