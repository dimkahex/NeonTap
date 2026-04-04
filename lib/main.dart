import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/services/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Sfx.initAudio();
  await Sfx.reloadFromPrefs(allowStartBgm: false);

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const NeonPulseApp());
}

