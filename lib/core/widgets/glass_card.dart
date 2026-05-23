import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';

/// Premium frosted-glass card – optimized for performance.
/// Uses solid semi-transparent backgrounds instead of expensive BackdropFilter.
/// On dark themes the visual difference is minimal, but GPU savings are massive.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final double glowIntensity;
  final double blurAmount; // kept for API compat, but not used anymore

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.padding,
    this.borderRadius,
    this.glowColor,
    this.glowIntensity = 0.0,
    this.blurAmount = 20,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(18);
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: br,
        // Solid semi-transparent background that mimics glass look on dark bg
        color: const Color(0xFF1A1A26).withValues(alpha: 0.85),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
        boxShadow: glowColor != null && glowIntensity > 0
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: glowIntensity * 0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
