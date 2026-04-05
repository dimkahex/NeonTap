import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/ui/main_ring_hud_painter.dart';
import 'src/ui/neon_background.dart';
import 'src/ui/neon_circle_painter.dart';
import 'src/ui/ring_guide_painter.dart';
import 'src/ui/spiral_overlay.dart';
import 'src/ui/static_score_rings_painter.dart';

/// Visual-only preview of ring layers (no gameplay, no audio).
///
/// Run from project root:
/// `flutter run -t lib/ring_preview_main.dart`
///
/// Adjust `_demoRadius` below to see the stack at different sizes.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
  runApp(const _RingPreviewApp());
}

class _RingPreviewApp extends StatelessWidget {
  const _RingPreviewApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RingPreviewPage(),
    );
  }
}

class RingPreviewPage extends StatefulWidget {
  const RingPreviewPage({super.key});

  @override
  State<RingPreviewPage> createState() => _RingPreviewPageState();
}

class _RingPreviewPageState extends State<RingPreviewPage> {
  static const double _maxRadius = 270;
  static const double _demoRadius = 140;
  static const double _pulse = 0.25;

  static const double _ringHalfWidthPx = 30;
  static const double _bandGrazeOuterPx = 52;
  static const double _bandRimOuterPx = 72;
  static const double _bandEdgeOuterPx = 92;

  final ValueNotifier<Offset> _centerOffset = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _centerOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned.fill(
              child: SpiralOverlay(
                centerOffset: _centerOffset,
                enabled: true,
                intensity: 0.45,
                score: 100,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: NeonCirclePainter(
                  radius: _demoRadius,
                  maxRadius: _maxRadius,
                  pulse: _pulse,
                  missFlash: 0,
                  centerOffset: _centerOffset.value,
                  hideMainRingStroke: true,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomPaint(
                      painter: StaticScoreRingsPainter(centerOffset: _centerOffset.value),
                      child: const SizedBox.expand(),
                    ),
                    CustomPaint(
                      painter: MainRingHudPainter(
                        radius: _demoRadius,
                        maxRadius: _maxRadius,
                        pulse: _pulse,
                        centerOffset: _centerOffset.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                    CustomPaint(
                      painter: RingGuidePainter(
                        centerOffset: _centerOffset.value,
                        ringRadius: _demoRadius,
                        halfWidth: _ringHalfWidthPx,
                        bandGrazeOuter: _bandGrazeOuterPx,
                        bandRimOuter: _bandRimOuterPx,
                        bandEdgeOuter: _bandEdgeOuterPx,
                        opacity: 1,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Preview — not the game\n'
                    'flutter run -t lib/ring_preview_main.dart\n'
                    'Edit _demoRadius in lib/ring_preview_main.dart',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                          height: 1.35,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
