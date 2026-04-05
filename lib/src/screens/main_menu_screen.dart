import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../services/sfx.dart';
import '../app_version.dart';
import '../ui/neon_background.dart';
import '../ui/neon_button.dart';
import '../ui/game_help_dialog.dart';
import 'leaderboard_screen.dart';
import 'game_screen.dart';
import 'profile_screen.dart';
import 'versus_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  static const String route = '/menu';

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(Sfx.startBackgroundMusic());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.taglineOneTap,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.4,
                    ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => showGameHelpDialog(context),
                  icon: const Icon(Icons.help_outline, size: 22, color: Color(0xFF35E6FF)),
                  label: Text(
                    l10n.menuHelp,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF35E6FF),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: l10n.menuPlay,
                subtitle: l10n.menuPlaySubtitle,
                icon: Icons.play_arrow,
                onPressed: () => Navigator.of(context).pushNamed(GameScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: l10n.menuLeaderboard,
                subtitle: l10n.menuLeaderboardSubtitle,
                icon: Icons.leaderboard,
                onPressed: () => Navigator.of(context).pushNamed(LeaderboardScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: l10n.menuVersus,
                subtitle: l10n.menuVersusSubtitle,
                icon: Icons.sports_mma,
                onPressed: () => Navigator.of(context).pushNamed(VersusScreen.route),
              ),
              const SizedBox(height: 12),
              NeonButton(
                label: l10n.menuProfile,
                subtitle: l10n.menuProfileSubtitle,
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
                l10n.menuFooterRankings,
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

