import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/l10n/app_translations.dart';

/// Kaaba coordinates (Mecca, Saudi Arabia)
const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});
  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  double? _heading;           // device compass heading (degrees from North)
  double? _qiblaDirection;    // bearing to Kaaba from current position
  Position? _position;
  String _status = 'Initialisation...';
  bool _hasError = false;
  StreamSubscription<CompassEvent>? _compassSub;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCompass();
  }

  Future<void> _initCompass() async {
    // ── 1. Check location permission ──
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      setState(() {
        _status = t(context, 'qibla_error_perm');
        _hasError = true;
      });
      return;
    }

    // ── 2. Check location service ──
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = t(context, 'qibla_error_gps');
        _hasError = true;
      });
      return;
    }

    // ── 3. Get current position ──
    setState(() => _status = t(context, 'qibla_loading'));
    try {
      _position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Impossible d\'obtenir la position';
        _hasError = true;
      });
      return;
    }

    // ── 4. Calculate Qibla bearing ──
    _qiblaDirection = _calculateQiblaBearing(
      _position!.latitude,
      _position!.longitude,
    );

    setState(() => _status = 'Boussole active');

    // ── 5. Start compass stream ──
    _compassSub = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() => _heading = event.heading);
      }
    });
  }

  /// Calculate great-circle bearing from current position to Kaaba
  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lng1 = lng * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final lng2 = _kaabaLng * math.pi / 180;
    final dLng = lng2 - lng1;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = _qiblaDirection ?? 0;
    final heading = _heading ?? 0;
    // The needle rotation: Qibla bearing minus compass heading
    final needleRotation = (qiblaAngle - heading) * math.pi / 180;
    // Compass rotation: negative heading to make compass stable
    final compassRotation = -heading * math.pi / 180;
    final isReady = _qiblaDirection != null && _heading != null;

    // Calculate how close the phone is pointing to Qibla
    double alignmentDeg = 0;
    if (isReady) {
      alignmentDeg = ((qiblaAngle - heading) % 360 + 360) % 360;
      if (alignmentDeg > 180) alignmentDeg = 360 - alignmentDeg;
    }
    final isAligned = isReady && alignmentDeg < 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Subtle radial glow ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    AppColors.gold.withValues(alpha: isAligned ? 0.06 : 0.03),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        color: Colors.white70,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        t(context, 'qibla_direction').toUpperCase(),
                        style: AppTextStyles.caption.copyWith(
                          letterSpacing: 2,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Kaaba info card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFF2A2418).withValues(alpha: 0.8),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '🕋',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'La Kaaba - الكعبة',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: const Color(0xFFF5EDE0),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'La Mecque, Arabie Saoudite',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isReady)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${qiblaAngle.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ── Main compass ──
                if (_hasError)
                  _ErrorView(status: _status, onRetry: () {
                    setState(() { _hasError = false; _status = 'Initialisation...'; });
                    _initCompass();
                  })
                else if (!isReady)
                  Column(
                    children: [
                      SizedBox(
                        width: 50, height: 50,
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(_status, style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      )),
                    ],
                  )
                else
                  _CompassWidget(
                    compassRotation: compassRotation,
                    needleRotation: needleRotation,
                    isAligned: isAligned,
                    alignmentDeg: alignmentDeg,
                    pulseAnimation: _pulseCtrl,
                  ),

                const Spacer(),

                // ── Bottom info ──
                if (isReady)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isAligned
                            ? AppColors.gold.withValues(alpha: 0.08)
                            : AppColors.surfaceLight.withValues(alpha: 0.3),
                        border: Border.all(
                          color: isAligned
                              ? AppColors.gold.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.06),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAligned
                                  ? AppColors.gold.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                            child: Icon(
                              isAligned
                                  ? Icons.check_circle_rounded
                                  : Icons.explore_outlined,
                              color: isAligned ? AppColors.gold : AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAligned
                                      ? t(context, 'qibla_aligned')
                                      : t(context, 'qibla_turn'),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isAligned
                                        ? AppColors.gold
                                        : AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAligned
                                      ? t(context, 'qibla_perfect')
                                      : '${t(context, 'qibla_offset')}: ${alignmentDeg.toStringAsFixed(1)}° — ${t(context, 'qibla_align_arrow')}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_position != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      '📍 ${_position!.latitude.toStringAsFixed(4)}°N, ${_position!.longitude.toStringAsFixed(4)}°E',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compass Widget ────────────────────────────────────────────────────────
class _CompassWidget extends StatelessWidget {
  final double compassRotation;
  final double needleRotation;
  final bool isAligned;
  final double alignmentDeg;
  final AnimationController pulseAnimation;

  const _CompassWidget({
    required this.compassRotation,
    required this.needleRotation,
    required this.isAligned,
    required this.alignmentDeg,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.78;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer glow when aligned ──
          if (isAligned)
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (_, __) => Container(
                width: size + 20,
                height: size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(
                        alpha: 0.08 + 0.06 * pulseAnimation.value,
                      ),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

          // ── Compass rose (rotates with device heading) ──
          AnimatedRotation(
            turns: compassRotation / (2 * math.pi),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: CustomPaint(
              size: Size(size, size),
              painter: _CompassRosePainter(),
            ),
          ),

          // ── Qibla needle (points toward Kaaba) ──
          AnimatedRotation(
            turns: needleRotation / (2 * math.pi),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _QiblaNeedle(size: size, isAligned: isAligned),
          ),

          // ── Center dot ──
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? AppColors.gold : const Color(0xFFF5EDE0),
              boxShadow: [
                BoxShadow(
                  color: (isAligned ? AppColors.gold : Colors.white)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Qibla Needle ──────────────────────────────────────────────────────────
class _QiblaNeedle extends StatelessWidget {
  final double size;
  final bool isAligned;
  const _QiblaNeedle({required this.size, required this.isAligned});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The needle line pointing up
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 3,
              height: size * 0.38,
              margin: EdgeInsets.only(top: size * 0.06),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isAligned ? AppColors.gold : const Color(0xFFE8C078),
                    isAligned
                        ? AppColors.gold.withValues(alpha: 0.3)
                        : const Color(0xFFE8C078).withValues(alpha: 0.2),
                  ],
                ),
                boxShadow: isAligned
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
          // Kaaba icon at the tip
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: size * 0.01),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAligned
                    ? AppColors.gold.withValues(alpha: 0.2)
                    : const Color(0xFF2A2418),
                border: Border.all(
                  color: isAligned
                      ? AppColors.gold
                      : const Color(0xFFE8C078).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isAligned
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  '🕋',
                  style: TextStyle(fontSize: isAligned ? 20 : 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compass Rose Painter ─────────────────────────────────────────────────
class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Outer ring ──
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFE8C078).withValues(alpha: 0.25);
    canvas.drawCircle(center, radius - 10, outerRingPaint);

    // ── Inner ring ──
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFFE8C078).withValues(alpha: 0.12);
    canvas.drawCircle(center, radius - 40, innerRingPaint);

    // ── Degree marks ──
    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * math.pi / 180;
      final isCardinal = deg % 90 == 0;
      final isMajor = deg % 30 == 0;
      final isMinor = deg % 15 == 0;

      double innerR, outerR;
      double strokeW;
      double alpha;

      if (isCardinal) {
        innerR = radius - 28;
        outerR = radius - 10;
        strokeW = 2.0;
        alpha = 0.7;
      } else if (isMajor) {
        innerR = radius - 24;
        outerR = radius - 10;
        strokeW = 1.2;
        alpha = 0.4;
      } else if (isMinor) {
        innerR = radius - 20;
        outerR = radius - 10;
        strokeW = 0.8;
        alpha = 0.25;
      } else {
        innerR = radius - 16;
        outerR = radius - 10;
        strokeW = 0.5;
        alpha = 0.12;
      }

      final p1 = center + Offset(math.cos(rad) * innerR, math.sin(rad) * innerR);
      final p2 = center + Offset(math.cos(rad) * outerR, math.sin(rad) * outerR);

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFFE8C078).withValues(alpha: alpha)
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Cardinal direction labels ──
    final cardinals = [
      (0, 'N', const Color(0xFFE8C078)),
      (90, 'E', const Color(0xFFF5EDE0)),
      (180, 'S', const Color(0xFFF5EDE0)),
      (270, 'W', const Color(0xFFF5EDE0)),
    ];

    for (final (deg, label, color) in cardinals) {
      final rad = (deg - 90) * math.pi / 180;
      final labelR = radius - 48;
      final pos = center + Offset(math.cos(rad) * labelR, math.sin(rad) * labelR);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: label == 'N' ? 18 : 14,
            fontWeight: label == 'N' ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // ── Intercardinal labels ──
    final intercardinals = [
      (45, 'NE'),
      (135, 'SE'),
      (225, 'SW'),
      (315, 'NW'),
    ];

    for (final (deg, label) in intercardinals) {
      final rad = (deg - 90) * math.pi / 180;
      final labelR = radius - 48;
      final pos = center + Offset(math.cos(rad) * labelR, math.sin(rad) * labelR);

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: const Color(0xFFF5EDE0).withValues(alpha: 0.35),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Error View ───────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String status;
  final VoidCallback onRetry;
  const _ErrorView({required this.status, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sunset.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.location_disabled_rounded,
              color: AppColors.sunset,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            status,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t(context, 'qibla_error_desc'),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(t(context, 'qibla_retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
