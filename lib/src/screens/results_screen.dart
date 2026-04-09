import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../game/run_result.dart';
import '../game/run_stats.dart';
import '../services/results_share.dart';
import '../ui/neon_background.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  static const String route = '/results';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final RunResult r = args is RunResult
        ? args
        : const RunResult(
            score: 0,
            bestCombo: 1,
            isNewBestScore: false,
            bestScore: 0,
            rankEstimate: 99999,
            breakdown: JudgementBreakdown(),
            lifetimeRunIndex: 0,
          );

    return Scaffold(
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 8),
              Text(
                r.score == 0 ? l10n.resultsDefeat : l10n.resultsRunOver,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 16),
              _StatTile(label: l10n.resultsFinalScore, value: r.score.toString()),
              const SizedBox(height: 10),
              if (r.lifetimeRunIndex > 0)
                _StatTile(
                  label: l10n.resultsRunNumber,
                  value: r.lifetimeRunIndex.toString(),
                ),
              if (r.lifetimeRunIndex > 0) const SizedBox(height: 10),
              _StatTile(
                label: l10n.resultsAccuracy,
                value: '${r.breakdown.accuracyPercent.toStringAsFixed(1)}%',
                subtitle: l10n.resultsHits(r.breakdown.totalHits),
              ),
              const SizedBox(height: 10),
              _StatTile(
                label: l10n.resultsHitBreakdown,
                value: _breakdownLine(l10n, r.breakdown),
                small: true,
              ),
              const SizedBox(height: 10),
              _StatTile(label: l10n.resultsBestCombo, value: 'x${r.bestCombo}'),
              const SizedBox(height: 10),
              _StatTile(
                label: l10n.resultsBestScore,
                value: r.bestScore.toString(),
                badge: r.isNewBestScore ? l10n.resultsNewBest : null,
              ),
              const SizedBox(height: 10),
              _StatTile(label: l10n.resultsRankEstimate, value: '#${r.rankEstimate}'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(GameScreen.route),
                child: Text(l10n.resultsPlayAgain),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _openShareSheet(context, r),
                child: Text(l10n.resultsShare),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(MainMenuScreen.route),
                child: Text(l10n.resultsMenu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openShareSheet(BuildContext context, RunResult r) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF0C1024),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.resultsSharePickPlatform,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        unawaited(_shareWithLoader(context, r, ShareTemplate.tiktok));
                      },
                      child: Text(l10n.sharePlatformTikTok),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        unawaited(_shareWithLoader(context, r, ShareTemplate.instagram));
                      },
                      child: Text(l10n.sharePlatformInstagram),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.resultsShareHintFormats,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _shareWithLoader(BuildContext context, RunResult r, ShareTemplate template) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final BuildContext rootContext = context;

  // Show a lightweight loader so it doesn't feel like a freeze.
  showDialog<void>(
    context: rootContext,
    barrierDismissible: false,
    builder: (BuildContext d) {
      return Dialog(
        backgroundColor: const Color(0xFF0C1024),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFF35E6FF).withValues(alpha: 0.35), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.resultsSharePreparing,
                  style: Theme.of(d).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  try {
    // Yield one frame so the dialog paints before heavy work starts.
    await Future<void>.delayed(const Duration(milliseconds: 16));

    // ignore: use_build_context_synchronously
    final XFile file = await ResultsShareService.prepareShareFile(context: rootContext, result: r, template: template);
    if (!rootContext.mounted) return;
    Navigator.of(rootContext, rootNavigator: true).pop(); // loader

    // Don't await: some platforms only complete after returning from external app.
    unawaited(ResultsShareService.sharePrepared(context: rootContext, result: r, file: file));
  } catch (_) {
    if (rootContext.mounted) {
      Navigator.of(rootContext, rootNavigator: true).maybePop(); // loader
      ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(content: Text(l10n.resultsShareFailed)));
    }
  }
}

String _breakdownLine(AppLocalizations l10n, JudgementBreakdown b) {
  return l10n.resultsBreakdown(b.perfect, b.cool, b.good, b.ok);
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.badge,
    this.subtitle,
    this.small = false,
  });

  final String label;
  final String value;
  final String? badge;
  final String? subtitle;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final TextStyle? valueStyle = small
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white.withValues(alpha: 0.92),
            )
        : Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF35E6FF), width: 1.1),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(value, style: valueStyle),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 0.4,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null) ...<Widget>[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFF2CFF7B).withValues(alpha: 0.18),
                border: Border.all(color: const Color(0xFF2CFF7B), width: 1.0),
              ),
              child: Text(
                badge!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: const Color(0xFF2CFF7B),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

