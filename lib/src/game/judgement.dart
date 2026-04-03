enum HitJudgement {
  /// Wide outer band — minimal points (easier aim).
  graze,
  /// Second wide band — minimal points.
  rim,
  /// Outermost scoring band — minimal points.
  edge,
  ok,
  ultra,
  perfect,
  good,
  miss,
}

extension HitJudgementUi on HitJudgement {
  String get label => switch (this) {
        HitJudgement.graze => 'GRAZE',
        HitJudgement.rim => 'RIM',
        HitJudgement.edge => 'EDGE',
        HitJudgement.ok => 'OK',
        HitJudgement.ultra => 'ULTRA',
        HitJudgement.perfect => 'PERFECT',
        HitJudgement.good => 'GOOD',
        HitJudgement.miss => 'MISS',
      };

  int get basePoints => switch (this) {
        HitJudgement.graze => 1,
        HitJudgement.rim => 1,
        HitJudgement.edge => 1,
        HitJudgement.ok => 2,
        HitJudgement.ultra => 10,
        HitJudgement.perfect => 5,
        HitJudgement.good => 2,
        HitJudgement.miss => 0,
      };
}

