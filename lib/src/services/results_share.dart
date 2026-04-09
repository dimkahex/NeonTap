import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../game/run_result.dart';

enum ShareTemplate { tiktok, instagram }

extension ShareTemplateUi on ShareTemplate {
  // Use a lighter render size to avoid UI stalls on mid/low devices.
  // Most social apps accept this and upscale if needed.
  Size get pixelSize => const Size(720, 1280); // 9:16
}

class ResultsShareService {
  ResultsShareService._();

  static Future<XFile> prepareShareFile({
    required BuildContext context,
    required RunResult result,
    required ShareTemplate template,
  }) async {
    final Uint8List png = await _renderPng(context: context, result: result, template: template);

    final Directory dir = await getTemporaryDirectory();
    final String name = switch (template) {
      ShareTemplate.tiktok => 'neonpulse_tiktok',
      ShareTemplate.instagram => 'neonpulse_instagram',
    };
    final File f = File('${dir.path}/$name.png');
    await f.writeAsBytes(png, flush: true);
    return XFile(f.path, mimeType: 'image/png');
  }

  static Future<void> sharePrepared({
    required BuildContext context,
    required RunResult result,
    required XFile file,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[file], text: l10n.resultsShareText(result.score)),
    );
  }

  static Future<Uint8List> _renderPng({
    required BuildContext context,
    required RunResult result,
    required ShareTemplate template,
  }) async {
    final Size size = template.pixelSize;
    final ui.Image img = await _drawShareImage(context: context, size: size, result: result, template: template);
    final ByteData? bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List() ?? Uint8List(0);
  }

  static Future<ui.Image> _drawShareImage({
    required BuildContext context,
    required Size size,
    required RunResult result,
    required ShareTemplate template,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final ui.Image? bg = await _loadTemplate(template);
    final bool hasTemplate = bg != null;
    if (bg != null) {
      final Rect dst = Offset.zero & size;
      final Rect src = Rect.fromLTWH(0, 0, bg.width.toDouble(), bg.height.toDouble());
      canvas.drawImageRect(bg, src, dst, Paint());
    } else {
      // Fallback background (keeps sharing usable until templates are provided).
      final Rect rect = Offset.zero & size;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            Offset(0, size.height),
            <Color>[
              const Color(0xFF0B0D1C),
              const Color(0xFF0C1024),
              const Color(0xFF12002A),
            ],
            <double>[0.0, 0.55, 1.0],
          ),
      );
    }

    final Color accent = switch (template) {
      ShareTemplate.tiktok => const Color(0xFF25F4EE),
      ShareTemplate.instagram => const Color(0xFFE1306C),
    };
    final String platform = switch (template) {
      ShareTemplate.tiktok => l10n.sharePlatformTikTok,
      ShareTemplate.instagram => l10n.sharePlatformInstagram,
    };

    // Coordinates tuned for 1080x1920 templates.
    final double left = 150;
    double y = 160;

    final TextStyle pillStyle = TextStyle(
      color: accent,
      fontSize: 26,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
    );
    final Size pillText = _measure(platform, pillStyle);
    final Rect pill = Rect.fromLTWH(size.width - 150 - pillText.width - 26, y + 6, pillText.width + 26, 44);
    canvas.drawRRect(RRect.fromRectAndRadius(pill, const Radius.circular(999)), Paint()..color = accent.withValues(alpha: 0.16));
    canvas.drawRRect(
      RRect.fromRectAndRadius(pill, const Radius.circular(999)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.85),
    );
    _tp(canvas, text: platform, at: Offset(pill.left + 13, pill.top + 10), style: pillStyle);
    y += 140;

    if (!hasTemplate) {
      _tp(
        canvas,
        text: l10n.resultsFinalScore,
        at: Offset(left, y),
        style: const TextStyle(
          color: Color(0xB3FFFFFF),
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
        ),
      );
      y += 50;
    }

    _tp(
      canvas,
      text: result.score.toString(),
      at: Offset(left, y),
      style: TextStyle(
        color: accent.withValues(alpha: 0.95),
        fontSize: 132,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        shadows: <Shadow>[Shadow(color: accent.withValues(alpha: 0.35), blurRadius: 10)],
      ),
    );
    y += 160;

    // Stats box area (template provides the containers).
    y = _kv(canvas, size.width, left, y, l10n.resultsBestCombo, 'x${result.bestCombo}', accent);
    y = _kv(
      canvas,
      size.width,
      left,
      y + 12,
      l10n.resultsAccuracy,
      '${result.breakdown.accuracyPercent.toStringAsFixed(1)}%',
      accent,
    );

    y += 38;
    if (!hasTemplate) {
      _tp(
        canvas,
        text: l10n.resultsHitBreakdown,
        at: Offset(left, y),
        style: const TextStyle(
          color: Color(0xB3FFFFFF),
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
      y += 42;
    } else {
      // Template already says BREAKDOWN; align values a bit below it.
      y += 54;
    }

    _tp(
      canvas,
      text: l10n.resultsBreakdown(result.breakdown.perfect, result.breakdown.cool, result.breakdown.good, result.breakdown.ok),
      at: Offset(left, y),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: 42,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );

    if (!hasTemplate) {
      _tp(
        canvas,
        text: l10n.resultsShareFooter,
        at: Offset(left, size.height - 240),
        style: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        maxWidth: size.width - 300,
        align: TextAlign.center,
      );
    }

    final ui.Picture pic = recorder.endRecording();
    return pic.toImage(size.width.toInt(), size.height.toInt());
  }

  static Future<ui.Image?> _loadTemplate(ShareTemplate template) async {
    final String asset = switch (template) {
      ShareTemplate.tiktok => 'assets/branding/share_templates/share_tiktok_720x1280.png',
      ShareTemplate.instagram => 'assets/branding/share_templates/share_instagram_720x1280.png',
    };
    try {
      final ByteData data = await rootBundle.load(asset);
      final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }
}

void _tp(
  Canvas canvas, {
  required String text,
  required Offset at,
  required TextStyle style,
  double? maxWidth,
  TextAlign align = TextAlign.left,
}) {
  final TextPainter tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: maxWidth == null ? 1 : null,
  )..layout(maxWidth: maxWidth ?? double.infinity);
  tp.paint(canvas, at);
}

Size _measure(String text, TextStyle style) {
  final TextPainter tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  return tp.size;
}

double _kv(Canvas canvas, double totalWidth, double x, double y, String k, String v, Color accent) {
  _tp(
    canvas,
    text: k,
    at: Offset(x, y),
    style: const TextStyle(
      color: Color(0xB3FFFFFF),
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );
  final TextStyle vStyle = TextStyle(
    color: accent.withValues(alpha: 0.92),
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
  );
  final Size vs = _measure(v, vStyle);
  _tp(
    canvas,
    text: v,
    at: Offset(totalWidth - 90 - 60 - vs.width, y - 2),
    style: vStyle,
  );
  return y + 40;
}

