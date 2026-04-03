import 'package:flutter/material.dart';

import '../ui/neon_background.dart';
import 'challenges_screen.dart';

class VersusScreen extends StatelessWidget {
  const VersusScreen({super.key});

  static const String route = '/versus';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VERSUS')),
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'REVENGE A FRIEND',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Асинхронные вызовы: выбери друга и окно времени.\n'
                'Считается лучший один забег в окне.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(ChallengesScreen.route),
                child: const Text('OPEN CHALLENGES'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('BACK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

