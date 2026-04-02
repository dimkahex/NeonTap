import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase/firebase_bootstrap.dart';
import 'screens/arena_screen.dart';
import 'screens/game_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/profile_screen.dart';
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
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: if Firebase isn't configured yet, app still works offline.
    FirebaseBootstrap.ensureGuestAuth();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme baseText = GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEON PULSE',
      theme: buildNeonTheme(baseText),
      initialRoute: SplashScreen.route,
      routes: <String, WidgetBuilder>{
        SplashScreen.route: (_) => const SplashScreen(),
        MainMenuScreen.route: (_) => const MainMenuScreen(),
        ArenaScreen.route: (_) => const ArenaScreen(),
        VersusScreen.route: (_) => const VersusScreen(),
        GameScreen.route: (_) => const GameScreen(),
        ResultsScreen.route: (_) => const ResultsScreen(),
        ProfileScreen.route: (_) => const ProfileScreen(),
      },
    );
  }
}

