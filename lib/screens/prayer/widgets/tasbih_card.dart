import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/l10n/app_translations.dart';
import 'package:mobplay/core/l10n/locale_provider.dart';

class TasbihCard extends StatefulWidget {
  const TasbihCard({super.key});

  @override
  State<TasbihCard> createState() => _TasbihCardState();
}

class _TasbihCardState extends State<TasbihCard> with TickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  int _dailyProgress = 0;
  final int _dailyTarget = 99;
  
  final List<Map<String, String>> _dhikrPresets = [
    {'key': 'subhanallah', 'en': 'SubhanAllah', 'ar': 'سُبْحَانَ ٱللَّٰهِ'},
    {'key': 'alhamdulillah', 'en': 'Alhamdulillah', 'ar': 'ٱلْحَمْدُ لِلَّٰهِ'},
    {'key': 'allahu_akbar', 'en': 'Allahu Akbar', 'ar': 'ٱللَّٰهُ أَكْبَرُ'},
  ];
  
  int _selectedDhikrIndex = 0;
  bool _isVibrationEnabled = true;
  
  // Animation controllers for premium effects
  late AnimationController _tapCtrl;
  late Animation<double> _scaleAnim;
  
  late AnimationController _haloCtrl;
  late Animation<double> _haloOpacity;
  late Animation<double> _haloScale;
  
  late AnimationController _pulseCtrl; // Soft breathing cycle behind card

  @override
  void initState() {
    super.initState();
    
    // Tap shrink scale
    _tapCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOutCubic),
    );

    // Tap pulse ripple (halo)
    _haloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _haloScale = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _haloCtrl, curve: Curves.easeOutCubic),
    );
    _haloOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _haloCtrl, curve: Curves.linear));

    // Breathing card ambient glow
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _haloCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_count >= _target) return;
    
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    
    // Reset and trigger tap anims
    _tapCtrl.forward().then((_) => _tapCtrl.reverse());
    _haloCtrl.forward(from: 0.0);
    
    setState(() {
      _count++;
      _dailyProgress++;
    });

    if (_count == _target) {
      if (_isVibrationEnabled) {
        HapticFeedback.heavyImpact();
      }
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            _selectedDhikrIndex = (_selectedDhikrIndex + 1) % _dhikrPresets.length;
            _count = 0;
          });
        }
      });
    }
  }

  void _reset() {
    if (_isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    setState(() => _count = 0);
  }

  void _selectPreset(int index) {
    if (_isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _selectedDhikrIndex = index;
      _count = 0;
    });
  }

  void _cycleTarget() {
    if (_isVibrationEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      if (_target == 33) {
        _target = 99;
      } else if (_target == 99) {
        _target = 100;
      } else {
        _target = 33;
      }
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressRatio = (_count % _target) / _target;
    final beadAngle = progressRatio * 2 * math.pi - (math.pi / 2);

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final pulseVal = _pulseCtrl.value;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFF101117), // Rich velvet dark AMOLED background
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.04 + (pulseVal * 0.03)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.02 + (pulseVal * 0.03)),
                blurRadius: 36,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              children: [
                // ── Top Header Row ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    t(context, 'tasbih_current').toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      letterSpacing: 1.8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "$_dailyProgress",
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    " / $_dailyTarget ${t(context, 'total')}",
                                    style: TextStyle(
                                      color: AppColors.textMuted.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12), // Prevent right-side controls from colliding
                    
                    // Action controls (Vibrate + Reset)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Vibrate Toggle Pill
                        GestureDetector(
                          onTap: () {
                            setState(() => _isVibrationEnabled = !_isVibrationEnabled);
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isVibrationEnabled 
                                  ? AppColors.gold.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                color: _isVibrationEnabled
                                    ? AppColors.gold.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.05),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              _isVibrationEnabled ? Icons.vibration : Icons.portable_wifi_off_rounded,
                              color: _isVibrationEnabled ? AppColors.goldLight : AppColors.textMuted,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Custom Target Config Pill
                        GestureDetector(
                          onTap: _cycleTarget,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.track_changes_rounded, size: 12, color: AppColors.gold),
                                const SizedBox(width: 4),
                                Text(
                                  "$_target",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
 
                        // Reset Button
                        GestureDetector(
                          onTap: _reset,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 0.8,
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded, 
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 28),
                
                // ── Dhikr Segmented Futuristic Slider Track ─────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                      width: 0.8,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = (constraints.maxWidth - 8) / _dhikrPresets.length;
                      return Stack(
                        children: [
                          // Sliding Selector Track Indicator
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.fastOutSlowIn,
                            left: _selectedDhikrIndex * tabWidth + 4,
                            top: 4,
                            bottom: 4,
                            width: tabWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Static preset labels on top
                          Row(
                            children: List.generate(_dhikrPresets.length, (index) {
                              final isSelected = _selectedDhikrIndex == index;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectPreset(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: 38,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Increased safety margin to prevent collisions
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        t(context, 'dhikr_${_dhikrPresets[index]['key']}'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          letterSpacing: -0.3, // Extra spacing room for longer words
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? const Color(0xFF0F0F14) : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 38),
                
                // ── Holographic Circular Progress & Core Count Button ────────
                GestureDetector(
                  onTapDown: (_) => _onTap(),
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Holographic Ripple Halo Ring (triggered on tap)
                        AnimatedBuilder(
                          animation: _haloCtrl,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _haloScale.value,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: _haloOpacity.value),
                                    width: 4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Soft Ambient Backlight Glow
                        Container(
                          width: 145, height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.08 + (progressRatio * 0.08)),
                                blurRadius: 36,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: const Color(0xFF0A0520).withValues(alpha: 0.4),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),

                        // Circular Progress Ring Frame
                        SizedBox(
                          width: 145, height: 145,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progressRatio),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            builder: (ctx, val, _) {
                              return CircularProgressIndicator(
                                value: val,
                                strokeWidth: 5,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.white.withValues(alpha: 0.04),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                              );
                            }
                          ),
                        ),

                        // Futuristic Active Orbiting Bead (Dot) matching exact angle
                        Positioned.fill(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: -math.pi / 2, end: beadAngle),
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            builder: (context, angle, _) {
                              const double radius = 145 / 2;
                              final double x = radius * math.cos(angle);
                              final double y = radius * math.sin(angle);
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: radius + x - 6,
                                    top: radius + y - 6,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Beautiful Center count Display (Frosted Glass Cylinder)
                        Container(
                          width: 115, height: 115,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.09),
                                Colors.white.withValues(alpha: 0.01),
                              ],
                              stops: const [0.3, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12), 
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "$_count",
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                      height: 1.0,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  "${t(context, 'target').toUpperCase()} $_target",
                                  style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                
                // ── Arabic Calligraphy Display with Soft Radial Blur ────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.08),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Container(
                    key: ValueKey<int>(_selectedDhikrIndex),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 48,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _dhikrPresets[_selectedDhikrIndex]['ar']!,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 32,
                                  color: AppColors.goldLight,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.gold,
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        if (context.read<LocaleProvider>().locale != 'ar') ...[
                          const SizedBox(height: 8),
                          Text(
                            t(context, 'dhikr_${_dhikrPresets[_selectedDhikrIndex]['key']}'),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
