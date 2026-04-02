enum HitJudgement {
  ultra,
  perfect,
  good,
  miss,
}

extension HitJudgementUi on HitJudgement {
  String get label => switch (this) {
        HitJudgement.ultra => 'ULTRA',
        HitJudgement.perfect => 'PERFECT',
        HitJudgement.good => 'GOOD',
        HitJudgement.miss => 'MISS',
      };

  int get basePoints => switch (this) {
        HitJudgement.ultra => 10,
        HitJudgement.perfect => 5,
        HitJudgement.good => 2,
        HitJudgement.miss => 0,
      };
}

