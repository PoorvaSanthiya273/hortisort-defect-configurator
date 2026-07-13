import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DefectPainter extends CustomPainter {
  final String defectId;

  DefectPainter({required this.defectId});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    final bg = Paint()..color = const Color(0xFFF0E6D3);
    canvas.drawCircle(c, r, bg);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = const Color(0xFFC4A882)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    switch (defectId) {
      case 'D01':
        _green(canvas, c, r);
      case 'D02':
        _cracks(canvas, c, r);
      case 'D03':
        _stones(canvas, c, r);
      case 'D04':
        _rhizo(canvas, c, r);
      case 'D05':
        _aging(canvas, c, r);
      case 'D06':
        _rotten(canvas, c, r);
      case 'D07':
        _fresh(canvas, c, r);
      case 'D08':
        _blackspot(canvas, c, r);
      case 'D09':
        _scab(canvas, c, r);
      case 'D10':
        _misshape(canvas, c, r);
      case 'D11':
        _leaf(canvas, c, r);
    }
  }

  void _green(Canvas c, Offset o, double r) {
    final p = Paint()..color = AppTheme.hortisortGreen.withValues(alpha: 0.6);
    c.drawCircle(Offset(o.dx + r * 0.25, o.dy - r * 0.15), r * 0.22, p);
    c.drawCircle(Offset(o.dx - r * 0.15, o.dy + r * 0.25), r * 0.18, p);
    c.drawCircle(Offset(o.dx + r * 0.1, o.dy + r * 0.3), r * 0.13, p);
  }

  void _cracks(Canvas c, Offset o, double r) {
    final p = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    c.drawLine(Offset(o.dx - r * 0.4, o.dy - r * 0.3),
        Offset(o.dx + r * 0.15, o.dy + r * 0.4), p);
    c.drawLine(Offset(o.dx + r * 0.15, o.dy + r * 0.4),
        Offset(o.dx + r * 0.35, o.dy + r * 0.15), p);
    c.drawLine(Offset(o.dx - r * 0.15, o.dy - r * 0.5),
        Offset(o.dx - r * 0.25, o.dy + r * 0.05), p);
  }

  void _stones(Canvas c, Offset o, double r) {
    final p = Paint()..color = const Color(0xFF757575);
    final path = Path()
      ..moveTo(o.dx - r * 0.25, o.dy + r * 0.15)
      ..lineTo(o.dx - r * 0.05, o.dy + r * 0.45)
      ..lineTo(o.dx + r * 0.25, o.dy + r * 0.25)
      ..lineTo(o.dx + r * 0.35, o.dy - r * 0.1)
      ..lineTo(o.dx + r * 0.05, o.dy - r * 0.35)
      ..lineTo(o.dx - r * 0.25, o.dy - r * 0.15)
      ..close();
    c.drawPath(path, p);
    c.drawCircle(Offset(o.dx + r * 0.35, o.dy - r * 0.25), r * 0.1,
        Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.5));
  }

  void _rhizo(Canvas c, Offset o, double r) {
    final p = Paint()..color = const Color(0xFF212121).withValues(alpha: 0.55);
    c.drawCircle(Offset(o.dx - r * 0.15, o.dy - r * 0.2), r * 0.14, p);
    c.drawCircle(Offset(o.dx + r * 0.25, o.dy), r * 0.16, p);
    c.drawCircle(Offset(o.dx, o.dy + r * 0.3), r * 0.11, p);
    c.drawCircle(Offset(o.dx - r * 0.3, o.dy + r * 0.1), r * 0.09, p);
    c.drawCircle(Offset(o.dx + r * 0.1, o.dy - r * 0.3), r * 0.07, p);
  }

  void _aging(Canvas c, Offset o, double r) {
    final p = Paint()
      ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    c.drawArc(
        Rect.fromCircle(
            center: Offset(o.dx - r * 0.05, o.dy + r * 0.05), radius: r * 0.35),
        -0.6,
        2.2,
        false,
        p);
    c.drawArc(
        Rect.fromCircle(center: Offset(o.dx + r * 0.1, o.dy), radius: r * 0.28),
        0.3,
        2.0,
        false,
        p);
  }

  void _rotten(Canvas c, Offset o, double r) {
    final p = Paint()..color = const Color(0xFF4E342E).withValues(alpha: 0.65);
    final path = Path()
      ..moveTo(o.dx - r * 0.35, o.dy)
      ..quadraticBezierTo(
          o.dx - r * 0.15, o.dy - r * 0.45, o.dx + r * 0.1, o.dy - r * 0.25)
      ..quadraticBezierTo(
          o.dx + r * 0.25, o.dy + r * 0.1, o.dx + r * 0.05, o.dy + r * 0.35)
      ..quadraticBezierTo(
          o.dx - r * 0.25, o.dy + r * 0.15, o.dx - r * 0.35, o.dy)
      ..close();
    c.drawPath(path, p);
    c.drawCircle(Offset(o.dx + r * 0.12, o.dy - r * 0.05), r * 0.16,
        Paint()..color = const Color(0xFF3E2723));
  }

  void _fresh(Canvas c, Offset o, double r) {
    c.drawCircle(Offset(o.dx, o.dy - r * 0.05), r * 0.4,
        Paint()..color = const Color(0xFFFFF8E1));
    c.drawCircle(Offset(o.dx, o.dy), r * 0.32,
        Paint()..color = const Color(0xFFE8D5A3).withValues(alpha: 0.6));
    c.drawLine(
        Offset(o.dx - r * 0.25, o.dy + r * 0.25),
        Offset(o.dx + r * 0.25, o.dy + r * 0.1),
        Paint()
          ..color = const Color(0xFF8D6E63)
          ..strokeWidth = 1);
  }

  void _blackspot(Canvas c, Offset o, double r) {
    final p = Paint()..color = const Color(0xFF212121);
    c.drawCircle(Offset(o.dx + r * 0.2, o.dy - r * 0.1), r * 0.18, p);
    c.drawCircle(Offset(o.dx - r * 0.15, o.dy + r * 0.2), r * 0.14, p);
    c.drawCircle(Offset(o.dx - r * 0.1, o.dy - r * 0.25), r * 0.11, p);
    c.drawCircle(Offset(o.dx + r * 0.28, o.dy + r * 0.18), r * 0.09, p);
  }

  void _scab(Canvas c, Offset o, double r) {
    final p = Paint()..color = const Color(0xFF795548).withValues(alpha: 0.5);
    final path = Path()
      ..moveTo(o.dx - r * 0.15, o.dy - r * 0.35)
      ..quadraticBezierTo(
          o.dx + r * 0.1, o.dy - r * 0.45, o.dx + r * 0.25, o.dy - r * 0.15)
      ..quadraticBezierTo(
          o.dx + r * 0.15, o.dy + r * 0.25, o.dx - r * 0.1, o.dy + r * 0.35)
      ..quadraticBezierTo(
          o.dx - r * 0.35, o.dy + r * 0.1, o.dx - r * 0.15, o.dy - r * 0.35)
      ..close();
    c.drawPath(path, p);
  }

  void _misshape(Canvas c, Offset o, double r) {
    final path = Path()
      ..moveTo(o.dx - r * 0.25, o.dy - r * 0.45)
      ..quadraticBezierTo(
          o.dx + r * 0.1, o.dy - r * 0.55, o.dx + r * 0.45, o.dy - r * 0.25)
      ..quadraticBezierTo(
          o.dx + r * 0.6, o.dy + r * 0.1, o.dx + r * 0.25, o.dy + r * 0.45)
      ..quadraticBezierTo(
          o.dx - r * 0.1, o.dy + r * 0.55, o.dx - r * 0.45, o.dy + r * 0.25)
      ..quadraticBezierTo(
          o.dx - r * 0.55, o.dy - r * 0.15, o.dx - r * 0.25, o.dy - r * 0.45)
      ..close();
    c.drawPath(path, Paint()..color = const Color(0xFFF0E6D3));
    c.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFA1887F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _leaf(Canvas c, Offset o, double r) {
    final path = Path()
      ..moveTo(o.dx, o.dy - r * 0.55)
      ..quadraticBezierTo(
          o.dx + r * 0.35, o.dy - r * 0.15, o.dx + r * 0.25, o.dy + r * 0.25)
      ..quadraticBezierTo(
          o.dx + r * 0.05, o.dy + r * 0.05, o.dx, o.dy + r * 0.45)
      ..quadraticBezierTo(
          o.dx - r * 0.05, o.dy + r * 0.05, o.dx - r * 0.25, o.dy + r * 0.25)
      ..quadraticBezierTo(
          o.dx - r * 0.35, o.dy - r * 0.15, o.dx, o.dy - r * 0.55)
      ..close();
    c.drawPath(path, Paint()..color = AppTheme.hortisortGreen);
    c.drawLine(
        Offset(o.dx, o.dy - r * 0.45),
        Offset(o.dx, o.dy + r * 0.35),
        Paint()
          ..color = AppTheme.hortisortGreen
          ..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant DefectPainter oldDelegate) =>
      oldDelegate.defectId != defectId;
}
