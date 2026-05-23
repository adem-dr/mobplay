import 'package:flutter/material.dart';

/// ── iOS-Inspired Warm Islamic Color Palette ──────────────────────────────
class AppColors {
  AppColors._();

  // ── Backgrounds (warm dark, not cold) ──────────────────────────────────
  static const Color background     = Color(0xFF0F0F14);
  static const Color cardBg         = Color(0xFF1A1A24);
  static const Color surfaceLight   = Color(0xFF222230);
  static const Color surfaceElevated = Color(0xFF2A2A3A);

  // ── Islamic Gold & Accent Palette ──────────────────────────────────────
  static const Color gold           = Color(0xFFD4A052);
  static const Color goldLight      = Color(0xFFE8C078);
  static const Color goldDark       = Color(0xFFA67C3C);
  static const Color emerald        = Color(0xFF34C772);
  static const Color emeraldDark    = Color(0xFF1B9E4B);
  static const Color teal           = Color(0xFF3CBFAE);
  static const Color rose           = Color(0xFFE8637A);
  static const Color lavender       = Color(0xFF9B8FD4);
  static const Color sky            = Color(0xFF5BA3F5);
  static const Color sunset         = Color(0xFFF5A76C);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF2F0ED);
  static const Color textSecondary  = Color(0xFF9A96A6);
  static const Color textMuted      = Color(0xFF5A566B);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color primary        = gold;
  static const Color secondary      = emerald;
  static const Color error          = Color(0xFFEF5350);
  static const Color surface        = cardBg;
  static const Color divider        = Color(0xFF2E2E3D);

  // ── iOS-style frosty glass ─────────────────────────────────────────────
  static const Color glassBg        = Color(0x1AFFFFFF);
  static const Color glassBorder    = Color(0x14FFFFFF);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const Gradient goldGradient = LinearGradient(
    colors: [goldLight, gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF2ED88A), emerald, emeraldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient warmGradient = LinearGradient(
    colors: [
      Color(0xFF0F0F14),
      Color(0xFF161622),
      Color(0xFF1A1520),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient prayerGradient = LinearGradient(
    colors: [
      Color(0xFF1A1030),
      Color(0xFF0F1828),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Kept for backward compat
  static const Color neonCyan   = gold;
  static const Color neonPurple = lavender;
  static const Color neonPink   = rose;
  static const Color neonGold   = gold;
  static const Color neonGreen  = emerald;
  static const Color neonRed    = error;

  static const Gradient primaryGradient = goldGradient;
  static const Gradient deepGradient    = warmGradient;
}
