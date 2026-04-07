import 'dart:async' show unawaited;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext ctx) {
            // Reuse the same dialog styling as help.
            return Dialog(
              backgroundColor: const Color(0xFF0C1024),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: const Color(0xFF35E6FF).withValues(alpha: 0.45), width: 1.2),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 36, 22, 22),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l10n.versusHelpTitle,
                              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: const Color(0xFFE8F4FF),
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.versusHelpBody,
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                    height: 1.45,
                                    color: Colors.white.withValues(alpha: 0.88),
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
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
