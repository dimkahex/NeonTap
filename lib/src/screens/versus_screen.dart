import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../ui/neon_background.dart';
import 'challenges_screen.dart';

class VersusScreen extends StatelessWidget {
  const VersusScreen({super.key});

  static const String route = '/versus';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.versusHistoryTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.versusOpenChallenges,
            onPressed: () => Navigator.of(context).pushNamed(ChallengesScreen.route),
          ),
        ],
      ),
      body: NeonBackground(
        child: StreamBuilder<List<Challenge>>(
          stream: ChallengeService.watchMyChallenges(),
          builder: (BuildContext context, AsyncSnapshot<List<Challenge>> snap) {
            final int now = DateTime.now().millisecondsSinceEpoch;
            final List<Challenge> all = snap.data ?? <Challenge>[];
            final List<Challenge> history = all
                .where(
                  (c) =>
                      c.status == ChallengeStatus.completed ||
                      c.status == ChallengeStatus.declined ||
                      c.status == ChallengeStatus.cancelled ||
                      c.isOver ||
                      now >= c.endsAtMs,
                )
                .toList(growable: false)
              ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

            if (snap.connectionState == ConnectionState.waiting && history.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (history.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.versusHistoryEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
              itemBuilder: (BuildContext context, int i) => _HistoryCard(c: history[i]),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.c});

  final Challenge c;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String vs = l10n.challengeVersus(c.fromName, c.toName);
    final String status = switch (c.status) {
      ChallengeStatus.pending => l10n.challengeStatusPending,
      ChallengeStatus.active => l10n.challengeStatusActive,
      ChallengeStatus.completed => l10n.challengeStatusCompleted,
      ChallengeStatus.declined => l10n.challengeStatusDeclined,
      ChallengeStatus.cancelled => l10n.challengeStatusCancelled,
    };
    final DateTime end = DateTime.fromMillisecondsSinceEpoch(c.endsAtMs);
    final String endLine = l10n.challengeEnds(end.toLocal().toString().split('.').first);

    return Card(
      color: Colors.black.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    vs,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white60,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              endLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(child: _MiniScore(name: c.fromName, score: c.fromBest, combo: c.fromBestCombo)),
                const SizedBox(width: 10),
                Expanded(child: _MiniScore(name: c.toName, score: c.toBest, combo: c.toBestCombo)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  const _MiniScore({required this.name, required this.score, required this.combo});

  final String name;
  final int score;
  final int combo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF)),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: const Color(0xFF35E6FF),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'x$combo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
