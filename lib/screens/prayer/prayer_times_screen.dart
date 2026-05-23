import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/services/prayer_times_service.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/prayer_icon.dart';
import 'package:mobplay/screens/qibla/qibla_compass_screen.dart';
import 'package:mobplay/core/l10n/locale_provider.dart';
import 'package:mobplay/core/l10n/app_translations.dart';
import 'package:mobplay/screens/prayer/widgets/tasbih_card.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _qiblaGlowCtrl;
  Timer? _countdownTimer;
  Duration _countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _qiblaGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final service = context.read<PrayerTimesService>();
      if (service.prayers.isNotEmpty) {
        final now = DateTime.now();
        final prayers = service.prayers;
        for (int i = 0; i < prayers.length; i++) {
          final parts = prayers[i].time.split(':');
          if (parts.length != 2) continue;
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final prayerTime = DateTime(now.year, now.month, now.day, h, m);
          if (prayerTime.isAfter(now)) {
            setState(() => _countdown = prayerTime.difference(now));
            return;
          }
        }
        // All passed → Fajr tomorrow
        final parts = prayers[0].time.split(':');
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final tomorrow = DateTime(now.year, now.month, now.day + 1, h, m);
        setState(() => _countdown = tomorrow.difference(now));
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    _qiblaGlowCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  PrayerIconType _mapIconType(IconType t) {
    switch (t) {
      case IconType.fajr: return PrayerIconType.fajr;
      case IconType.sunrise: return PrayerIconType.sunrise;
      case IconType.dhuhr: return PrayerIconType.dhuhr;
      case IconType.asr: return PrayerIconType.asr;
      case IconType.maghrib: return PrayerIconType.maghrib;
      case IconType.isha: return PrayerIconType.isha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PrayerTimesService>();
    context.watch<LocaleProvider>();
    final prayers = service.prayers;
    final nextIdx = service.nextPrayerIndex;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: service.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // ── Header ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hijri date badge + location
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.08),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PrayerIcon(
                                      type: PrayerIconType.moon,
                                      size: 14,
                                      color: AppColors.gold,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${service.hijriDate} ${service.hijriMonth} ${service.hijriYear}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Location pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: AppColors.textSecondary, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.city}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(t(context, 'prayer_schedule'),
                                    style: AppTextStyles.heading1.copyWith(
                                      fontSize: 28,
                                      height: 1.2,
                                    )),
                              ),
                              // Mosque icon
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.gold.withValues(alpha: 0.15),
                                      AppColors.goldDark.withValues(alpha: 0.08),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: PrayerIcon(
                                    type: PrayerIconType.mosque,
                                    size: 28,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Next Prayer Card ───────────────────────
                          _NextPrayerCard(
                            nextPrayer: service.nextPrayer,
                            countdown: _countdown,
                            mapIcon: _mapIconType,
                            pulseAnimation: _pulseCtrl,
                          ),

                          const SizedBox(height: 24),

                          // ── Qibla Direction — Premium CTA ──────────
                          _QiblaDirectionButton(
                            glowAnimation: _qiblaGlowCtrl,
                          ),

                          const SizedBox(height: 24),
                          
                          // ── Tasbih Premium Section ──────────
                          const TasbihCard(),

                          const SizedBox(height: 28),
                          Text(t(context, 'all_prayers'),
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // ── Prayer List ────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final prayer = prayers[index];
                          final isNext = index == nextIdx;
                          final isPast = index < nextIdx;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + index * 80),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _PrayerTile(
                                prayer: prayer,
                                isNext: isNext,
                                isPast: isPast,
                                mapIcon: _mapIconType,
                              ),
                            ),
                          );
                        },
                        childCount: prayers.length,
                      ),
                    ),
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  QIBLA DIRECTION — Premium Animated CTA Button
// ══════════════════════════════════════════════════════════════════════════
class _QiblaDirectionButton extends StatelessWidget {
  final AnimationController glowAnimation;

  const _QiblaDirectionButton({required this.glowAnimation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
      ),
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          final glowVal = glowAnimation.value;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1C2A1E),
                  Color.lerp(
                    const Color(0xFF162018),
                    const Color(0xFF1A2820),
                    glowVal,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Color.lerp(
                  AppColors.emerald.withValues(alpha: 0.15),
                  AppColors.emerald.withValues(alpha: 0.35),
                  glowVal,
                )!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.06 + 0.06 * glowVal),
                  blurRadius: 24 + 12 * glowVal,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            // Animated compass icon
            AnimatedBuilder(
              animation: glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.emerald.withValues(alpha: 0.18 + 0.08 * glowAnimation.value),
                        AppColors.teal.withValues(alpha: 0.10 + 0.05 * glowAnimation.value),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.15 + 0.1 * glowAnimation.value),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Transform.rotate(
                        angle: glowAnimation.value * math.pi * 0.1,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Compass icon
                      Icon(Icons.explore_rounded,
                          color: AppColors.emerald, size: 26),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(context, 'qibla_direction'),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t(context, 'qibla_subtitle'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.emerald.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow button
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.emerald.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.emerald, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  Next Prayer Card — warm beige/cream gradient
// ══════════════════════════════════════════════════════════════════════════
class _NextPrayerCard extends StatelessWidget {
  final PrayerTime? nextPrayer;
  final Duration countdown;
  final PrayerIconType Function(IconType) mapIcon;
  final AnimationController pulseAnimation;

  const _NextPrayerCard({
    required this.nextPrayer,
    required this.countdown,
    required this.mapIcon,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (nextPrayer == null) return const SizedBox.shrink();

    final h = countdown.inHours;
    final m = countdown.inMinutes % 60;
    final s = countdown.inSeconds % 60;
    final countdownStr = h > 0
        ? '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s'
        : '${m}m ${s.toString().padLeft(2, '0')}s';

    final iconColor = _getIconColor(nextPrayer!.iconType);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2418),
            Color(0xFF1E1A14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t(context, 'next_prayer').toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Pulsing live dot
                    AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, _) {
                        return Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emerald,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald.withValues(
                                    alpha: 0.3 + 0.3 * pulseAnimation.value),
                                blurRadius: 6 + 4 * pulseAnimation.value,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Custom icon
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: PrayerIcon(
                          type: mapIcon(nextPrayer!.iconType),
                          size: 26,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(context, nextPrayer!.name.toLowerCase()),
                            style: AppTextStyles.heading2.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF5EDE0),
                            ),
                          ),
                          if (context.read<LocaleProvider>().locale != 'ar') ...[
                            const SizedBox(height: 2),
                            Text(
                              nextPrayer!.nameAr,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: iconColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          nextPrayer!.time,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE8C078),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${t(context, 'in_time')} $countdownStr',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(IconType type) {
    switch (type) {
      case IconType.fajr: return const Color(0xFFB8A9D4);
      case IconType.sunrise: return const Color(0xFFE8B76C);
      case IconType.dhuhr: return AppColors.gold;
      case IconType.asr: return AppColors.goldLight;
      case IconType.maghrib: return const Color(0xFFD4876C);
      case IconType.isha: return const Color(0xFFCBB89D);  // warm beige — NOT blue
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  Prayer Tile
// ══════════════════════════════════════════════════════════════════════════
class _PrayerTile extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;
  final bool isPast;
  final PrayerIconType Function(IconType) mapIcon;

  const _PrayerTile({
    required this.prayer,
    required this.isNext,
    required this.isPast,
    required this.mapIcon,
  });

  Color get _iconColor {
    if (isNext) return AppColors.gold;
    if (isPast) return AppColors.textMuted;
    switch (prayer.iconType) {
      case IconType.fajr: return const Color(0xFFB8A9D4);
      case IconType.sunrise: return const Color(0xFFE8B76C);
      case IconType.dhuhr: return AppColors.gold;
      case IconType.asr: return AppColors.goldLight;
      case IconType.maghrib: return const Color(0xFFD4876C);
      case IconType.isha: return const Color(0xFFCBB89D);  // warm beige — NOT blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isNext
            ? AppColors.gold.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: isNext
              ? AppColors.gold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Custom icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: PrayerIcon(
                type: mapIcon(prayer.iconType),
                size: 20,
                color: _iconColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name (FR + AR)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t(context, prayer.name.toLowerCase()),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isPast
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (context.read<LocaleProvider>().locale != 'ar')
                  Text(
                    prayer.nameAr,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      color: isPast
                          ? AppColors.textMuted.withValues(alpha: 0.6)
                          : _iconColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Time
          Text(
            prayer.time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
              color: isNext
                  ? AppColors.gold
                  : isPast
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (isPast) ...[
            const SizedBox(width: 8),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.check_rounded,
                color: AppColors.gold.withValues(alpha: 0.7), size: 14),
            ),
          ],
          if (isNext) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
