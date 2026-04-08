import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../ui/neon_background.dart';
import 'create_challenge_screen.dart';

class VersusScreen extends StatelessWidget {
  const VersusScreen({super.key});

  static const String route = '/versus';

  static void _showVersusIntro(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0C1024),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: const Color(0xFF35E6FF).withValues(alpha: 0.45), width: 1.2),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          l10n.versusHelpTitle,
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: const Color(0xFFE8F4FF),
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.versusHelpBody,
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                                color: Colors.white.withValues(alpha: 0.88),
                                letterSpacing: 0.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _showVersusIntro(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.versusTitle),
      ),
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.versusHeadline,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.versusBody,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.35),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CreateChallengeScreen()),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.challengesMakeChallenge),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const VersusHistoryScreen()),
                  ),
                  icon: const Icon(Icons.history),
                  label: Text(l10n.versusHistoryTitle),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<List<Challenge>>(
                  stream: ChallengeService.watchMyChallenges(),
                  builder: (BuildContext context, AsyncSnapshot<List<Challenge>> snap) {
                    final int now = DateTime.now().millisecondsSinceEpoch;
                    final List<Challenge> all = snap.data ?? <Challenge>[];
                    final List<Challenge> current = all
                        .where(
                          (c) =>
                              c.status == ChallengeStatus.pending ||
                              (c.status == ChallengeStatus.active && now < c.endsAtMs),
                        )
                        .toList(growable: false)
                      ..sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

                    if (snap.connectionState == ConnectionState.waiting && current.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (current.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.challengesEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: current.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0x22FFFFFF)),
                      itemBuilder: (BuildContext context, int i) => _CurrentChallengeCard(c: current[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentChallengeCard extends StatelessWidget {
  const _CurrentChallengeCard({required this.c});

  final Challenge c;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool over = c.isOver || c.status == ChallengeStatus.completed;
    final String vs = l10n.challengeVersus(c.fromName, c.toName);
    final String status = switch (c.status) {
      ChallengeStatus.pending => l10n.challengeStatusPending,
      ChallengeStatus.active => over ? l10n.challengeStatusFinishing : l10n.challengeStatusActive,
      ChallengeStatus.completed => l10n.challengeStatusCompleted,
      ChallengeStatus.declined => l10n.challengeStatusDeclined,
      ChallengeStatus.cancelled => l10n.challengeStatusCancelled,
    };
    final DateTime end = DateTime.fromMillisecondsSinceEpoch(c.endsAtMs);
    final String endLine = l10n.challengeEnds(end.toLocal().toString().split('.').first);

    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final bool iAmFrom = uid != null && uid == c.fromUid;
    final bool iAmTo = uid != null && uid == c.toUid;

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
                        color: over ? Colors.white54 : const Color(0xFF35E6FF),
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: <Widget>[
                if (c.status == ChallengeStatus.pending && iAmTo) ...<Widget>[
                  ElevatedButton(
                    onPressed: () => ChallengeService.accept(c.id),
                    child: Text(l10n.challengeAccept),
                  ),
                  OutlinedButton(
                    onPressed: () => ChallengeService.decline(c.id),
                    child: Text(l10n.challengeDecline),
                  ),
                ],
                if (c.status == ChallengeStatus.pending && iAmFrom)
                  OutlinedButton(
                    onPressed: () => ChallengeService.cancel(c.id),
                    child: Text(l10n.challengeCancel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VersusHistoryScreen extends StatelessWidget {
  const VersusHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.versusHistoryTitle)),
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
