import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DefectImageGen {
  static final Map<String, ui.Image> _cache = {};

  static Future<ui.Image> get(String defectId) async {
    if (_cache.containsKey(defectId)) return _cache[defectId]!;
    final image = await _generate(defectId);
    _cache[defectId] = image;
    return image;
  }

  static Future<ui.Image> _generate(String defectId) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 160.0;
    final r = size / 2;
    final c = Offset(r, r);

    final path = Path();
    final angles = List.generate(24, (i) => (i / 24) * 3.14159 * 2);
    for (int i = 0; i < 24; i++) {
      final a = angles[i];
      final noise = (i % 3 == 0)
          ? 0.85
          : (i % 3 == 1)
              ? 0.9
              : 1.05;
      final x = c.dx + cos(a) * r * 0.82 * noise;
      final y = c.dy + sin(a) * r * 0.7 * noise;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final bgGrad = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFF5E6CA), Color(0xFFD4A574), Color(0xFFB8860B)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(const Rect.fromLTWH(0, 0, size, size));
    canvas.drawPath(path, bgGrad);

    final skinPaint = Paint()
      ..color = const Color(0xFFC4956A).withValues(alpha: 0.15);
    for (int i = 0; i < 60; i++) {
      canvas.drawCircle(
          Offset(c.dx + sin(i * 7.3) * r * 0.6, c.dy + cos(i * 5.7) * r * 0.5),
          2.5,
          skinPaint);
    }

    switch (defectId) {
      case 'D11':
        _leaf(canvas, c, r);
        break;
      default:
        _generic(canvas, c, r, defectId);
    }

    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF5C3A0A).withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    final picture = recorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  static void _leaf(Canvas c, Offset o, double r) {
    final lp = Paint()..color = AppTheme.hortisortGreen.withValues(alpha: 0.85);
    final lpath = Path()
      ..moveTo(o.dx, o.dy - r * 0.6)
      ..quadraticBezierTo(
          o.dx + r * 0.35, o.dy - r * 0.15, o.dx + r * 0.2, o.dy + r * 0.3)
      ..quadraticBezierTo(
          o.dx + r * 0.05, o.dy + r * 0.05, o.dx, o.dy + r * 0.45)
      ..quadraticBezierTo(
          o.dx - r * 0.05, o.dy + r * 0.05, o.dx - r * 0.2, o.dy + r * 0.3)
      ..quadraticBezierTo(
          o.dx - r * 0.35, o.dy - r * 0.15, o.dx, o.dy - r * 0.6)
      ..close();
    c.drawPath(lpath, lp);
    c.drawLine(
        Offset(o.dx, o.dy - r * 0.5),
        Offset(o.dx, o.dy + r * 0.35),
        Paint()
          ..color = AppTheme.hortisortGreen
          ..strokeWidth = 1.2);
  }

  static void _generic(Canvas c, Offset o, double r, String id) {
    final tp = TextPainter(
        text: TextSpan(
            text: id,
            style: const TextStyle(
                color: Color(0xFF8D6E63),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(c, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
  }
}
