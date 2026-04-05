enum HitJudgement {
  perfect,
  cool,
  good,
  ok,
  miss,
}

extension HitJudgementUi on HitJudgement {
  int get basePoints => switch (this) {
        HitJudgement.perfect => 8,
        HitJudgement.cool => 6,
        HitJudgement.good => 4,
        HitJudgement.ok => 2,
        HitJudgement.miss => 0,
      };
}
