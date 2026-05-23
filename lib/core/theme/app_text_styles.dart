import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── iOS-inspired clean typography ──────────────────────────────────────
  static const String _fontFamily = 'SF Pro Display';

  static const TextStyle heading1 = TextStyle(
    fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.5, height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.3, height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.35,
  );

  static const TextStyle neon = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.gold,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  // ── Arabic text style ─────────────────────────────────────────────────
  static const TextStyle arabic = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
    height: 1.8, letterSpacing: 1.0,
  );

  static const TextStyle arabicSmall = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    height: 1.6,
  );
}
