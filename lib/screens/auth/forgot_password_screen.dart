import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/auth_provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/glass_card.dart';
import 'package:mobplay/core/l10n/app_translations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  String? _localErr;
  
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _reset() async {
    setState(() => _localErr = null);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _localErr = t(context, 'enter_email'));
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _localErr = t(context, 'invalid_email'));
      return;
    }
    await context.read<AuthProvider>().resetPw(email);
    if (mounted && context.read<AuthProvider>().err == null) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayErr = auth.err ?? _localErr;

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            t(context, 'reset_password'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (context, child) {
                  final glowIntensity = _glowCtrl.value;
                  return GlassCard(
                    glowColor: AppColors.gold,
                    glowIntensity: 0.03 + (glowIntensity * 0.04), // Smooth breathing glow border
                    padding: const EdgeInsets.all(28),
                    borderRadius: BorderRadius.circular(24),
                    child: child!,
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: _sent 
                      ? Column(
                          key: const ValueKey('success_state'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cyber success checkmark ring
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.emerald.withValues(alpha: 0.2),
                                    AppColors.emerald.withValues(alpha: 0.03),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: AppColors.emerald.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 54,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t(context, 'email_sent'),
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t(context, 'check_inbox'),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),
                            
                            // Return Button (No overflow possible)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        t(context, 'back_login'),
                                        style: const TextStyle(
                                          color: Color(0xFF0F0F14),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('input_state'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Neon Gold Futuristic Lock Circle
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.gold.withValues(alpha: 0.18),
                                    AppColors.gold.withValues(alpha: 0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 54,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              t(context, 'forgot_password'),
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t(context, 'forgot_subtitle'),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Frosted Error Banner
                            if (displayErr != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        displayErr,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Futuristic Glass Text Field
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.black.withValues(alpha: 0.25),
                                hintText: t(context, 'email'),
                                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                                prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.gold, size: 20),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 0.8,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.gold,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Gold Gradient Reset Button (Using FittedBox to absolute protect text overflow)
                            GestureDetector(
                              onTap: () {
                                if (!auth.loading) {
                                  HapticFeedback.mediumImpact();
                                  _reset();
                                }
                              },
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: auth.loading ? 0.6 : 1.0,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.goldGradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: auth.loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF0F0F14),
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              t(context, 'reset_password'),
                                              style: const TextStyle(
                                                color: Color(0xFF0F0F14),
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
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
    );
  }
}
