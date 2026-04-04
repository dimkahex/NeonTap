import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../ui/neon_background.dart';
import 'challenges_screen.dart';

class VersusScreen extends StatelessWidget {
  const VersusScreen({super.key});

  static const String route = '/versus';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.versusTitle)),
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.versusHeadline,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.versusBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(ChallengesScreen.route),
                child: Text(l10n.versusOpenChallenges),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.versusBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
