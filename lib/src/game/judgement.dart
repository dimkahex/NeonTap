enum HitJudgement {
  perfect,
  good,
  ok,
  miss,
}

extension HitJudgementUi on HitJudgement {
  int get basePoints => switch (this) {
        HitJudgement.perfect => 10,
        HitJudgement.good => 5,
        HitJudgement.ok => 2,
        HitJudgement.miss => 0,
      };
}
