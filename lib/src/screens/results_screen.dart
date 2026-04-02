import 'package:flutter/material.dart';

import '../game/run_result.dart';
import '../ui/neon_background.dart';
import 'game_screen.dart';
import 'main_menu_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  static const String route = '/results';

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final RunResult r = args is RunResult
        ? args
        : const RunResult(
            score: 0,
            bestCombo: 1,
            isNewBestScore: false,
            bestScore: 0,
            rankEstimate: 99999,
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
                r.score == 0 ? 'DEFEAT' : 'RUN OVER',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 16),
              _StatTile(label: 'FINAL SCORE', value: r.score.toString()),
              const SizedBox(height: 10),
              _StatTile(label: 'BEST COMBO', value: 'x${r.bestCombo}'),
              const SizedBox(height: 10),
              _StatTile(
                label: 'BEST SCORE',
                value: r.bestScore.toString(),
                badge: r.isNewBestScore ? 'NEW BEST' : null,
              ),
              const SizedBox(height: 10),
              _StatTile(label: 'RANK ESTIMATE', value: '#${r.rankEstimate}'),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(GameScreen.route),
                child: const Text('PLAY AGAIN'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Phase 1: placeholder share text.
                  final String text = 'Я набрал ${r.score} в NEON PULSE!';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(text)),
                  );
                },
                child: const Text('SHARE'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(MainMenuScreen.route),
                child: const Text('MENU'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.badge});

  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF35E6FF), width: 1.1),
        color: Colors.black.withOpacity(0.18),
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
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
          if (badge != null) ...<Widget>[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color(0xFF2CFF7B).withOpacity(0.18),
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

