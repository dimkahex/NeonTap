import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/firebase/firebase_bootstrap.dart';
import 'src/services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional (offline-first), but if configured it should be ready early
  // so score sync doesn't miss the first completed run.
  await FirebaseBootstrap.ensureGuestAuth();

  await Sfx.initAudio();
  await Sfx.reloadFromPrefs(allowStartBgm: false);

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const NeonPulseApp());
}

