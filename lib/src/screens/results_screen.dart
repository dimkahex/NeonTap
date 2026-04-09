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

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  static const String route = '/results';

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  RunResult? _result;

  Future<XFile?>? _tiktokFile;
  Future<XFile?>? _instagramFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_result != null) return;

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
    _result = r;

    // Pre-generate share images in background so tapping "Share" never freezes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tiktokFile ??= _prepareShare(template: ShareTemplate.tiktok);
      _instagramFile ??= _prepareShare(template: ShareTemplate.instagram);
      setState(() {});
    });
  }

  Future<XFile?> _prepareShare({required ShareTemplate template}) async {
    final RunResult? r = _result;
    if (r == null) return null;
    try {
      return await ResultsShareService.prepareShareFile(
        context: context,
        result: r,
        template: template,
      ).timeout(const Duration(seconds: 12));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final RunResult r = _result ??
        const RunResult(
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
                onPressed: () => _openShareSheet(r),
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

  Future<void> _openShareSheet(RunResult r) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Future<XFile?>? tiktokF = _tiktokFile;
    final Future<XFile?>? instaF = _instagramFile;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0C1024),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (BuildContext ctx) {
        Widget btn({
          required String label,
          required Future<XFile?>? future,
        }) {
          return FutureBuilder<XFile?>(
            future: future,
            builder: (BuildContext c, AsyncSnapshot<XFile?> snap) {
              final bool ready = snap.connectionState == ConnectionState.done && snap.data != null;
              return ElevatedButton(
                onPressed: ready
                    ? () {
                        Navigator.of(ctx).pop();
                        unawaited(ResultsShareService.sharePrepared(context: context, result: r, file: snap.data!));
                      }
                    : null,
                child: Text(ready ? label : l10n.resultsSharePreparing),
              );
            },
          );
        }

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
                    Expanded(child: btn(label: l10n.sharePlatformTikTok, future: tiktokF)),
                    const SizedBox(width: 12),
                    Expanded(child: btn(label: l10n.sharePlatformInstagram, future: instaF)),
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

