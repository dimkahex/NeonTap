import 'package:flutter/material.dart';

import '../ui/neon_background.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  static const String route = '/arena';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARENA')),
      body: NeonBackground(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'LIVE TOP-100',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Здесь будет LIVE TOP-100 + твоё место + кнопка “Challenge #1”.\n'
                'Phase 1: пока заглушка (онлайн слой подключим во 2 фазе).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 20),
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

