import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../game/run_result.dart';

enum ShareTemplate { tiktok, instagram }

extension ShareTemplateUi on ShareTemplate {
  Size get pixelSize => const Size(1080, 1920); // 9:16 (TikTok + IG Stories)
}

class ResultsShareService {
  ResultsShareService._();

  static Future<void> share({
    required BuildContext context,
    required RunResult result,
    required ShareTemplate template,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Uint8List png = await _renderPng(context: context, result: result, template: template);

    final Directory dir = await getTemporaryDirectory();
    final String name = switch (template) {
      ShareTemplate.tiktok => 'neonpulse_tiktok',
      ShareTemplate.instagram => 'neonpulse_instagram',
    };
    final File f = File('${dir.path}/$name.png');
    await f.writeAsBytes(png, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(f.path, mimeType: 'image/png')],
        text: l10n.resultsShareText(result.score),
      ),
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

    final Color accent = switch (template) {
      ShareTemplate.tiktok => const Color(0xFF25F4EE),
      ShareTemplate.instagram => const Color(0xFFE1306C),
    };
    final String platform = switch (template) {
      ShareTemplate.tiktok => l10n.sharePlatformTikTok,
      ShareTemplate.instagram => l10n.sharePlatformInstagram,
    };

    final Rect card = Rect.fromLTWH(90, 190, size.width - 180, size.height - 380);
    final RRect rr = RRect.fromRectAndRadius(card, const Radius.circular(56));
    canvas.drawRRect(rr, Paint()..color = const Color(0x33000000));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = accent.withValues(alpha: 0.80),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..color = accent.withValues(alpha: 0.12)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 18),
    );

    final double left = card.left + 60;
    double y = card.top + 70;

    _tp(
      canvas,
      text: 'NEONPULSE',
      at: Offset(left, y),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.95),
        fontSize: 54,
        fontWeight: FontWeight.w900,
        letterSpacing: 6,
      ),
    );

    final TextStyle pillStyle = TextStyle(
      color: accent,
      fontSize: 26,
      fontWeight: FontWeight.w900,
      letterSpacing: 2,
    );
    final Size pillText = _measure(platform, pillStyle);
    final Rect pill = Rect.fromLTWH(card.right - pillText.width - 60 - 26, y + 4, pillText.width + 26, 44);
    canvas.drawRRect(RRect.fromRectAndRadius(pill, const Radius.circular(999)), Paint()..color = accent.withValues(alpha: 0.16));
    canvas.drawRRect(
      RRect.fromRectAndRadius(pill, const Radius.circular(999)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.85),
    );
    _tp(canvas, text: platform, at: Offset(pill.left + 13, pill.top + 10), style: pillStyle);
    y += 120;

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

    _tp(
      canvas,
      text: result.score.toString(),
      at: Offset(left, y),
      style: TextStyle(
        color: accent.withValues(alpha: 0.95),
        fontSize: 140,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        shadows: <Shadow>[Shadow(color: accent.withValues(alpha: 0.50), blurRadius: 20)],
      ),
    );
    y += 170;

    y = _kv(canvas, size.width, left, y, l10n.resultsBestCombo, 'x${result.bestCombo}', accent);
    y = _kv(canvas, size.width, left, y + 10, l10n.resultsAccuracy, '${result.breakdown.accuracyPercent.toStringAsFixed(1)}%', accent);

    y += 38;
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

    _tp(
      canvas,
      text: l10n.resultsBreakdown(result.breakdown.perfect, result.breakdown.cool, result.breakdown.good, result.breakdown.ok),
      at: Offset(left, y),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: 44,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );

    _tp(
      canvas,
      text: l10n.resultsShareFooter,
      at: Offset(card.left + 60, card.bottom - 90),
      style: const TextStyle(
        color: Color(0x99FFFFFF),
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      maxWidth: card.width - 120,
      align: TextAlign.center,
    );

    final ui.Picture pic = recorder.endRecording();
    return pic.toImage(size.width.toInt(), size.height.toInt());
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

