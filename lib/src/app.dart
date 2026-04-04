import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import 'config/online_config.dart';
import 'firebase/firebase_bootstrap.dart';
import 'locale/app_locale_scope.dart';
import 'locale/locale_controller.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/game_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/versus_screen.dart';
import 'theme/neon_theme.dart';

class NeonPulseApp extends StatefulWidget {
  const NeonPulseApp({super.key});

  @override
  State<NeonPulseApp> createState() => _NeonPulseAppState();
}

class _NeonPulseAppState extends State<NeonPulseApp> {
  final LocaleController _locale = LocaleController();

  @override
  void initState() {
    super.initState();
    unawaited(_locale.load());
    if (kFirebaseOnlineFeaturesEnabled) {
      FirebaseBootstrap.ensureGuestAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme baseText = GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme);

    return ListenableBuilder(
      listenable: _locale,
      builder: (BuildContext context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NEON PULSE',
          locale: _locale.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildNeonTheme(baseText),
          initialRoute: SplashScreen.route,
          builder: (BuildContext context, Widget? child) {
            return AppLocaleScope(
              controller: _locale,
              child: child ?? const SizedBox.shrink(),
            );
          },
          routes: <String, WidgetBuilder>{
            SplashScreen.route: (_) => const SplashScreen(),
            MainMenuScreen.route: (_) => const MainMenuScreen(),
            LeaderboardScreen.route: (_) => const LeaderboardScreen(),
            ChallengesScreen.route: (_) => const ChallengesScreen(),
            VersusScreen.route: (_) => const VersusScreen(),
            GameScreen.route: (_) => const GameScreen(),
            ResultsScreen.route: (_) => const ResultsScreen(),
            ProfileScreen.route: (_) => const ProfileScreen(),
            SettingsScreen.route: (_) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
