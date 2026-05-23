import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/l10n/app_translations.dart';
import 'package:mobplay/core/l10n/locale_provider.dart';
import 'package:mobplay/models/adkar_model.dart';
import 'package:mobplay/screens/adkar/adkar_detail_screen.dart';

class AdkarScreen extends StatefulWidget {
  const AdkarScreen({super.key});

  @override
  State<AdkarScreen> createState() => _AdkarScreenState();
}

class _AdkarScreenState extends State<AdkarScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _copyInspiration(BuildContext context) {
    final day = DateTime.now().day;
    final idx = (day % 3) + 1;
    final textAr = t(context, 'meditation_${idx}_ar');
    final textTrans = t(context, 'meditation_${idx}_text');
    final source = t(context, 'meditation_${idx}_source');
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;

    final text = locale == 'ar'
        ? '$textAr\n($source)'
        : '$textAr\n$textTrans\n($source)';

    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(context, 'copied_to_clipboard')),
        backgroundColor: AppColors.gold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Sliver App Bar with rich visual styling
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                t(context, 'nav_adkar'),
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle glowing ambient light background
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.08),
                            blurRadius: 100,
                            spreadRadius: 40,
                          )
                        ],
                      ),
                    ),
                  ),
                  // Islamic geometric shape watermark
                  Positioned(
                    bottom: -20,
                    left: 20,
                    child: Icon(
                      Icons.star_border_purple500_rounded,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.02),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // INSPIRATION DU JOUR CARD (GORGEOUS GLASS WIDGET)
                _buildInspirationCard(context),
                const SizedBox(height: 28),
                
                // SECTION TITLE
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        t(context, 'proposed_invocations'),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // CATEGORIES
                AdkarCategoryCard(
                  titleAr: 'أذكار الصباح',
                  title: 'Adkar Sabah',
                  subtitle: 'Invocations du matin',
                  icon: Icons.brightness_5_rounded,
                  glowColor: AppColors.gold,
                  adkarList: AdkarData.sabah,
                  delay: 0,
                ),
                const SizedBox(height: 18),
                
                AdkarCategoryCard(
                  titleAr: 'أذكار المساء',
                  title: 'Adkar Massa',
                  subtitle: 'Invocations du soir',
                  icon: Icons.brightness_4_rounded,
                  glowColor: AppColors.sunset, // Warm sunset orange
                  adkarList: AdkarData.massa,
                  delay: 100,
                ),
                const SizedBox(height: 18),
                
                AdkarCategoryCard(
                  titleAr: 'أذكار النوم',
                  title: 'Adkar Layl',
                  subtitle: 'Invocations de la nuit',
                  icon: Icons.bedtime_rounded,
                  glowColor: AppColors.sky, // Soft evening blue
                  adkarList: AdkarData.layl,
                  delay: 200,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard(BuildContext context) {
    final day = DateTime.now().day;
    final idx = (day % 3) + 1;
    final textAr = t(context, 'meditation_${idx}_ar');
    final textTrans = t(context, 'meditation_${idx}_text');
    final source = t(context, 'meditation_${idx}_source');
    final locale = Provider.of<LocaleProvider>(context).locale;
    final isArabic = locale == 'ar';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D1B26),
            Color(0xFF14121A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background decor
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.menu_book_rounded,
                size: 140,
                color: AppColors.gold.withValues(alpha: 0.03),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            t(context, 'daily_meditation'),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _copyInspiration(context),
                        icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white60),
                        tooltip: 'Copier',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Arabic Text
                  Align(
                    alignment: isArabic ? Alignment.center : Alignment.centerRight,
                    child: Text(
                      textAr,
                      textAlign: isArabic ? TextAlign.center : TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  if (!isArabic) ...[
                    const SizedBox(height: 12),
                    // Translation (French/English)
                    Text(
                      textTrans,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  
                  // Source
                  Text(
                    source,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdkarCategoryCard extends StatefulWidget {
  final String titleAr;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final List<AdkarItem> adkarList;
  final int delay;

  const AdkarCategoryCard({
    super.key,
    required this.titleAr,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.adkarList,
    required this.delay,
  });

  @override
  State<AdkarCategoryCard> createState() => _AdkarCategoryCardState();
}

class _AdkarCategoryCardState extends State<AdkarCategoryCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1.0 - _fadeAnimation.value)),
            child: child,
          );
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF14151C), // Deep elegant charcoal
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.04),
                  blurRadius: 25,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GestureDetector(
                  onTapDown: (_) => _pressController.reverse(),
                  onTapCancel: () => _pressController.forward(),
                  onTapUp: (_) {
                    _pressController.forward();
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdkarDetailScreen(
                          title: widget.title,
                          titleAr: widget.titleAr,
                          glowColor: widget.glowColor,
                          adkarList: widget.adkarList,
                        ),
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
                    child: Row(
                      children: [
                        // Icon with sophisticated gradient and glow
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.glowColor.withValues(alpha: 0.16),
                                widget.glowColor.withValues(alpha: 0.03),
                              ],
                            ),
                            border: Border.all(
                              color: widget.glowColor.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.glowColor.withValues(alpha: 0.15),
                                blurRadius: 15,
                                spreadRadius: -5,
                              )
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.glowColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 18),
                        
                        // Category text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.titleAr,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: widget.glowColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Elegant arrow backplate
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: widget.glowColor.withValues(alpha: 0.7),
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
