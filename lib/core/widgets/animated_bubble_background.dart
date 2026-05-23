import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';

/// Premium mosque background with subtle floating shimmer animation.
/// The mosque image is static (cached), and only a tiny glow layer animates
/// every ~6 seconds — negligible GPU cost vs full-frame CustomPainter.
class AnimatedBubbleBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBubbleBackground({super.key, required this.child});

  @override
  State<AnimatedBubbleBackground> createState() => _AnimatedBubbleBackgroundState();
}

class _AnimatedBubbleBackgroundState extends State<AnimatedBubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Mosque image (cached at startup, never rebuilds) ──
        Image.asset(
          'assets/images/mosque_bg.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        // ── Dark gradient overlay for readability ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.15, 0.4, 0.7, 1.0],
              colors: [
                Color(0xD80F0F14),
                Color(0xC00F0F14),
                Color(0xAA0F0F14),
                Color(0xCC0F0F14),
                Color(0xF00F0F14),
              ],
            ),
          ),
        ),

        // ── Subtle animated glow that drifts slowly ──
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            final t = _shimmerCtrl.value;
            return CustomPaint(
              painter: _ShimmerPainter(t),
              size: Size.infinite,
            );
          },
        ),

        // ── Content ──
        widget.child,
      ],
    );
  }
}

/// Extremely lightweight painter — draws just 2 soft circles per frame.
/// The circles move very slowly (8s cycle) so the visual impact is subtle
/// but keeps the background feeling alive and not flat.
class _ShimmerPainter extends CustomPainter {
  final double t;
  const _ShimmerPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Golden glow drifting near top-right
    final p1 = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.025 + 0.015 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(
      Offset(
        size.width * 0.7 + math.sin(t * math.pi) * 30,
        size.height * 0.18 + math.cos(t * math.pi) * 15,
      ),
      140,
      p1,
    );

    // Warm amber glow drifting near bottom-left
    final p2 = Paint()
      ..color = const Color(0xFFD4876C).withValues(alpha: 0.012 + 0.008 * t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(
      Offset(
        size.width * 0.25 + math.cos(t * math.pi * 0.8) * 20,
        size.height * 0.72 + math.sin(t * math.pi * 0.6) * 18,
      ),
      110,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) => old.t != t;
}
