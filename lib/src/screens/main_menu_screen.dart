import 'package:flutter/material.dart';

import '../app_version.dart';
import '../ui/neon_background.dart';
import '../ui/neon_button.dart';
import 'arena_screen.dart';
import 'game_screen.dart';
import 'profile_screen.dart';
import 'versus_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const String route = '/menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                'NEON PULSE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'One tap. Pure skill.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.4,
                    ),
              ),
              const SizedBox(height: 22),
              NeonButton(
                label: 'PLAY',
                subtitle: 'Instant run — chase your best score',
                icon: Icons.play_arrow,
                onPressed: () => Navigator.of(context).pushNamed(GameScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'ARENA',
                subtitle: 'LIVE TOP-100 + Challenge #1',
                icon: Icons.public,
                onPressed: () => Navigator.of(context).pushNamed(ArenaScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'VERSUS',
                subtitle: 'Revenge a friend — code-based duels',
                icon: Icons.sports_mma,
                onPressed: () => Navigator.of(context).pushNamed(VersusScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: 'PROFILE',
                subtitle: 'Stats • Achievements • Share card',
                icon: Icons.person,
                onPressed: () => Navigator.of(context).pushNamed(ProfileScreen.route),
              ),
              const Spacer(),
              Text(
                kAppVersion,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Phase 1: Offline core • Firebase guest auth wired',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 0.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

