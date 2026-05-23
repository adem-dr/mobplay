import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom-painted prayer icons — no Material/Android emoji, pure vector art
class PrayerIcon extends StatelessWidget {
  final PrayerIconType type;
  final double size;
  final Color color;

  const PrayerIcon({
    super.key,
    required this.type,
    this.size = 22,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PrayerIconPainter(type: type, color: color),
    );
  }
}

enum PrayerIconType { fajr, sunrise, dhuhr, asr, maghrib, isha, mosque, moon }

class _PrayerIconPainter extends CustomPainter {
  final PrayerIconType type;
  final Color color;

  const _PrayerIconPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    switch (type) {
      case PrayerIconType.fajr:
        _drawFajr(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.sunrise:
        _drawSunrise(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.dhuhr:
        _drawDhuhr(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.asr:
        _drawAsr(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.maghrib:
        _drawMaghrib(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.isha:
        _drawIsha(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.mosque:
        _drawMosque(canvas, size, cx, cy, r, paint, fillPaint);
        break;
      case PrayerIconType.moon:
        _drawCrescentMoon(canvas, size, cx, cy, r, paint, fillPaint);
        break;
    }
  }

  // ── Fajr: crescent moon with a star ──
  void _drawFajr(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    // Crescent
    final moonPath = Path();
    moonPath.addArc(Rect.fromCircle(center: Offset(cx - r * 0.15, cy), radius: r), 0, math.pi * 2);
    final cutout = Path();
    cutout.addArc(Rect.fromCircle(center: Offset(cx + r * 0.35, cy - r * 0.15), radius: r * 0.75), 0, math.pi * 2);
    final crescent = Path.combine(PathOperation.difference, moonPath, cutout);
    canvas.drawPath(crescent, fill..color = color.withOpacity(0.8));

    // Small star
    _drawStar(canvas, Offset(cx + r * 0.65, cy - r * 0.5), r * 0.2, fill..color = color);
  }

  // ── Sunrise: half sun with rays above horizon ──
  void _drawSunrise(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    final horizonY = cy + r * 0.3;
    // Horizon line
    canvas.drawLine(
      Offset(cx - r * 1.1, horizonY),
      Offset(cx + r * 1.1, horizonY),
      stroke..color = color.withOpacity(0.4),
    );
    // Half sun
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, s.width, horizonY));
    canvas.drawCircle(Offset(cx, horizonY), r * 0.55, fill..color = color.withOpacity(0.7));
    canvas.restore();
    // Rays
    for (int i = 0; i < 5; i++) {
      final angle = math.pi + (math.pi / 6) * (i - 2);
      final x1 = cx + math.cos(angle) * r * 0.72;
      final y1 = horizonY + math.sin(angle) * r * 0.72;
      final x2 = cx + math.cos(angle) * r * 1.05;
      final y2 = horizonY + math.sin(angle) * r * 1.05;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke..color = color);
    }
  }

  // ── Dhuhr: full sun with 8 rays ──
  void _drawDhuhr(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    canvas.drawCircle(Offset(cx, cy), r * 0.4, fill..color = color);
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final x1 = cx + math.cos(angle) * r * 0.55;
      final y1 = cy + math.sin(angle) * r * 0.55;
      final x2 = cx + math.cos(angle) * r * 0.85;
      final y2 = cy + math.sin(angle) * r * 0.85;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke..color = color);
    }
  }

  // ── Asr: sun lower with long shadow ──
  void _drawAsr(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    final sunCx = cx + r * 0.3;
    final sunCy = cy - r * 0.1;
    canvas.drawCircle(Offset(sunCx, sunCy), r * 0.35, fill..color = color.withOpacity(0.85));
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x1 = sunCx + math.cos(angle) * r * 0.5;
      final y1 = sunCy + math.sin(angle) * r * 0.5;
      final x2 = sunCx + math.cos(angle) * r * 0.72;
      final y2 = sunCy + math.sin(angle) * r * 0.72;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke..color = color.withOpacity(0.6));
    }
    // Shadow line
    final shadowPath = Path()
      ..moveTo(cx - r * 0.8, cy + r * 0.6)
      ..lineTo(cx + r * 0.2, cy + r * 0.6)
      ..lineTo(cx - r * 0.5, cy + r * 0.6);
    canvas.drawLine(
      Offset(cx - r * 0.9, cy + r * 0.65),
      Offset(cx + r * 0.4, cy + r * 0.65),
      stroke..color = color.withOpacity(0.3),
    );
  }

  // ── Maghrib: sunset with half sun below horizon ──
  void _drawMaghrib(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    final horizonY = cy + r * 0.1;
    // Horizon
    canvas.drawLine(
      Offset(cx - r * 1.1, horizonY),
      Offset(cx + r * 1.1, horizonY),
      stroke..color = color.withOpacity(0.5),
    );
    // Sun sinking
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, s.width, horizonY));
    canvas.drawCircle(Offset(cx, horizonY + r * 0.15), r * 0.45, fill..color = color.withOpacity(0.6));
    canvas.restore();
    // Sky glow rays
    for (int i = 0; i < 3; i++) {
      final angle = math.pi + (math.pi / 4) * (i - 1);
      final x1 = cx + math.cos(angle) * r * 0.6;
      final y1 = horizonY + math.sin(angle) * r * 0.6;
      final x2 = cx + math.cos(angle) * r * 0.95;
      final y2 = horizonY + math.sin(angle) * r * 0.95;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), stroke..color = color.withOpacity(0.4));
    }
  }

  // ── Isha: crescent moon with 3 stars ──
  void _drawIsha(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    // Crescent
    final moonPath = Path();
    moonPath.addArc(Rect.fromCircle(center: Offset(cx - r * 0.1, cy + r * 0.05), radius: r * 0.65), 0, math.pi * 2);
    final cutout = Path();
    cutout.addArc(Rect.fromCircle(center: Offset(cx + r * 0.25, cy - r * 0.15), radius: r * 0.5), 0, math.pi * 2);
    final crescent = Path.combine(PathOperation.difference, moonPath, cutout);
    canvas.drawPath(crescent, fill..color = color);

    // Stars
    _drawStar(canvas, Offset(cx + r * 0.6, cy - r * 0.55), r * 0.12, fill);
    _drawStar(canvas, Offset(cx + r * 0.85, cy - r * 0.15), r * 0.09, fill);
    _drawStar(canvas, Offset(cx + r * 0.45, cy - r * 0.25), r * 0.07, fill);
  }

  // ── Mosque ──
  void _drawMosque(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    // Dome
    final domePath = Path()
      ..moveTo(cx - r * 0.6, cy + r * 0.1)
      ..quadraticBezierTo(cx, cy - r * 0.8, cx + r * 0.6, cy + r * 0.1);
    canvas.drawPath(domePath, stroke..color = color);

    // Base
    canvas.drawRect(
      Rect.fromLTRB(cx - r * 0.7, cy + r * 0.1, cx + r * 0.7, cy + r * 0.6),
      stroke..color = color,
    );

    // Minaret left
    canvas.drawRect(
      Rect.fromLTRB(cx - r * 0.9, cy - r * 0.3, cx - r * 0.75, cy + r * 0.6),
      stroke..color = color,
    );
    // Minaret top
    _drawStar(canvas, Offset(cx - r * 0.825, cy - r * 0.45), r * 0.1, fill..color = color);

    // Minaret right
    canvas.drawRect(
      Rect.fromLTRB(cx + r * 0.75, cy - r * 0.3, cx + r * 0.9, cy + r * 0.6),
      stroke..color = color,
    );
    _drawStar(canvas, Offset(cx + r * 0.825, cy - r * 0.45), r * 0.1, fill);

    // Crescent on top
    _drawStar(canvas, Offset(cx, cy - r * 0.65), r * 0.13, fill..color = color);

    // Door arch
    final doorPath = Path()
      ..moveTo(cx - r * 0.15, cy + r * 0.6)
      ..lineTo(cx - r * 0.15, cy + r * 0.3)
      ..quadraticBezierTo(cx, cy + r * 0.1, cx + r * 0.15, cy + r * 0.3)
      ..lineTo(cx + r * 0.15, cy + r * 0.6);
    canvas.drawPath(doorPath, stroke..color = color);
  }

  // ── Crescent moon ──
  void _drawCrescentMoon(Canvas canvas, Size s, double cx, double cy, double r,
      Paint stroke, Paint fill) {
    final moonPath = Path();
    moonPath.addArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.8), 0, math.pi * 2);
    final cutout = Path();
    cutout.addArc(Rect.fromCircle(center: Offset(cx + r * 0.4, cy - r * 0.25), radius: r * 0.6), 0, math.pi * 2);
    final crescent = Path.combine(PathOperation.difference, moonPath, cutout);
    canvas.drawPath(crescent, fill..color = color);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = (math.pi / 2.5) * i - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;
      final outerX = center.dx + math.cos(outerAngle) * radius;
      final outerY = center.dy + math.sin(outerAngle) * radius;
      final innerX = center.dx + math.cos(innerAngle) * radius * 0.4;
      final innerY = center.dy + math.sin(innerAngle) * radius * 0.4;
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PrayerIconPainter old) =>
      old.type != type || old.color != color;
}
