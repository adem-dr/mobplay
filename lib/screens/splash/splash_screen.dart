import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';

/// Full-screen intro splash. Calls [onDone] when complete.
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subOpacity;
  late final Animation<Offset> _subSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.35, 0.62, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 0.68, curve: Curves.easeOutCubic),
    ));

    _subOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.58, 0.85, curve: Curves.easeIn),
      ),
    );
    _subSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.58, 0.88, curve: Curves.easeOutCubic),
    ));

    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _entryCtrl.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _exitCtrl.forward();
      if (!mounted) return;
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation:
          Listenable.merge([_bgCtrl, _entryCtrl, _pulseCtrl, _exitCtrl]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _exitOpacity,
          child: Scaffold(
            backgroundColor: const Color(0xFF0A0A10),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Ambient background
                CustomPaint(
                  size: size,
                  painter: _SplashBgPainter(_bgCtrl.value),
                ),

                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildLogo(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: ShaderMask(
                            shaderCallback: (r) => const LinearGradient(
                              colors: [
                                AppColors.goldLight,
                                Colors.white,
                                AppColors.gold,
                              ],
                            ).createShader(r),
                            child: const Text(
                              'MobPlay',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      SlideTransition(
                        position: _subSlide,
                        child: FadeTransition(
                          opacity: _subOpacity,
                          child: const Text(
                            'Écoute du Coran  ·  القرآن الكريم',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Basmala at bottom
                Positioned(
                  bottom: 52,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _subOpacity,
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 60),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0x0AFFFFFF),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.gold),
                              minHeight: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          style: TextStyle(
                            color: Color(0x44FFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing glow
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.gold.withValues(alpha: 0.2 * _pulse.value),
                    blurRadius: 50 * _pulse.value,
                    spreadRadius: 6 * _pulse.value,
                  ),
                ],
              ),
            ),
          ),
          // Premium Gold Islamic App Logo
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background painter ───────────────────────────────────────────────────
class _SplashBgPainter extends CustomPainter {
  final double t;
  const _SplashBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A0A10), Color(0xFF10101E), Color(0xFF0A0A10)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final angle = t * math.pi * 2;

    // Gold orb
    final p1 = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(
      Offset(
        size.width * 0.3 + math.cos(angle * 0.4) * 20,
        size.height * 0.3 + math.sin(angle * 0.5) * 15,
      ),
      140,
      p1,
    );

    // Emerald orb
    final p2 = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    canvas.drawCircle(
      Offset(
        size.width * 0.7 + math.sin(angle * 0.3) * 18,
        size.height * 0.65 + math.cos(angle * 0.4) * 12,
      ),
      120,
      p2,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBgPainter old) => old.t != t;
}
