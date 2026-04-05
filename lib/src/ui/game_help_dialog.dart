import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Общее окно «как играть» — из главного меню и при первом кадре игры.
Future<void> showGameHelpDialog(BuildContext context) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (BuildContext ctx) {
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
                        l10n.helpDialogTitle,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: const Color(0xFFE8F4FF),
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.helpDialogBody,
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
  );
}
