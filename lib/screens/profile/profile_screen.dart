import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/auth_provider.dart';
import 'package:mobplay/providers/stats_provider.dart';
import 'package:mobplay/providers/favorites_provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/glass_card.dart';
import 'package:mobplay/core/l10n/locale_provider.dart';
import 'package:mobplay/core/l10n/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _notificationsOn = p.getBool('pref_notif') ?? true);
  }

  Future<void> _toggleNotif(bool v) async {
    setState(() => _notificationsOn = v);
    final p = await SharedPreferences.getInstance();
    await p.setBool('pref_notif', v);
  }

  void _showLangPicker() {
    final lp = context.read<LocaleProvider>();
    final langs = [
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'ar', 'label': 'العربية', 'flag': '🇸🇦'},
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(t(context, 'choose_lang'), style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          for (final l in langs)
            ListTile(
              leading: Text(l['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(l['label']!, style: AppTextStyles.bodyMedium),
              trailing: lp.locale == l['code']
                  ? const Icon(Icons.check_circle, color: AppColors.gold, size: 22)
                  : null,
              onTap: () {
                lp.setLocale(l['code']!);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 22),
          const SizedBox(width: 10),
          Text('MobPlay', style: AppTextStyles.titleMedium),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${t(context, 'version')} 1.0.0', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text(t(context, 'about_desc'),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 14),
          Center(child: Text('بسم الله الرحمن الرحيم',
            style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppColors.gold))),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t(context, 'close'), style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final fnCtrl = TextEditingController(text: user?.firstName ?? '');
    final lnCtrl = TextEditingController(text: user?.lastName ?? '');

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(t(context, 'edit_profile'), style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            _buildField(fnCtrl, t(context, 'firstname'), Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(lnCtrl, t(context, 'lastname'), Icons.badge_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final name = '${fnCtrl.text.trim()} ${lnCtrl.text.trim()}'.trim();
                  if (name.isNotEmpty) {
                    await auth.updateProfile(displayName: name);
                    if (ctx.mounted) Navigator.pop(ctx, true);
                  }
                },
                child: Text(t(context, 'save'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t(context, 'profile_updated')),
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _changePassword() async {
    final auth = context.read<AuthProvider>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isPending = false;
    String? localError;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      t(context, 'change_password'),
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (localError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t(context, localError!),
                              style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Current Password Field
                  TextField(
                    controller: currentCtrl,
                    obscureText: obscureCurrent,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: AppColors.gold,
                    decoration: InputDecoration(
                      labelText: t(context, 'current_password'),
                      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.gold,
                      ),
                      onPressed: () async {
                        final email = auth.user?.email;
                        if (email != null && email.isNotEmpty) {
                          setModalState(() {
                            isPending = true;
                            localError = null;
                          });
                          try {
                            await auth.resetPw(email);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(t(context, 'email_sent')),
                                backgroundColor: AppColors.gold,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ));
                            }
                          } catch (e) {
                            setModalState(() {
                              isPending = false;
                              localError = e.toString();
                            });
                          }
                        } else {
                          setModalState(() {
                            localError = 'invalid_email';
                          });
                        }
                      },
                      child: Text(
                        t(context, 'forgot_password'),
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // New Password Field
                  TextField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: AppColors.gold,
                    onChanged: (v) {
                      setModalState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: t(context, 'new_password'),
                      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm New Password Field
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    cursorColor: AppColors.gold,
                    onChanged: (v) {
                      setModalState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: t(context, 'confirm_new_password'),
                      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.gold, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                  
                  // Password match helper
                  if (newCtrl.text.isNotEmpty && confirmCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          newCtrl.text == confirmCtrl.text ? Icons.check_circle_outline : Icons.error_outline,
                          color: newCtrl.text == confirmCtrl.text ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            newCtrl.text == confirmCtrl.text
                                ? t(context, 'passwords_match')
                                : t(context, 'passwords_dont_match'),
                            style: TextStyle(
                              color: newCtrl.text == confirmCtrl.text ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: isPending
                          ? null
                          : () async {
                              final currentPw = currentCtrl.text.trim();
                              final newPw = newCtrl.text.trim();
                              final confirmPw = confirmCtrl.text.trim();

                              if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                                setModalState(() {
                                  localError = 'all_fields_required';
                                });
                                return;
                              }

                              if (newPw.length < 6) {
                                setModalState(() {
                                  localError = 'password_too_short';
                                });
                                return;
                              }

                              if (newPw != confirmPw) {
                                setModalState(() {
                                  localError = 'passwords_dont_match';
                                });
                                return;
                              }

                              setModalState(() {
                                isPending = true;
                                localError = null;
                              });

                              final success = await auth.changePassword(
                                currentPassword: currentPw,
                                newPassword: newPw,
                              );

                              if (success) {
                                if (ctx.mounted) Navigator.pop(ctx, true);
                              } else {
                                setModalState(() {
                                  isPending = false;
                                  localError = auth.err ?? 'error';
                                });
                              }
                            },
                      child: isPending
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                t(context, 'change_password'),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t(context, 'password_changed_success')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Widget _buildField(TextEditingController c, String label, IconData icon) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t(context, 'logout_confirm'), style: AppTextStyles.titleMedium),
        content: Text(t(context, 'logout_desc'),
          style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t(context, 'cancel'), style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t(context, 'logout'), style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = context.watch<StatsProvider>();
    final favCount = context.watch<FavoritesProvider>().favorites.length;
    final lp = context.watch<LocaleProvider>();

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(t(context, 'profile_title'), style: AppTextStyles.heading1)),
                    GestureDetector(
                      onTap: _editProfile,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 18),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // Avatar card
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 16)],
                        ),
                        child: Center(child: Text(
                          (user?.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                        )),
                      ),
                      const SizedBox(width: 18),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user?.displayName ?? t(context, 'guest'),
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '', style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.gold.withValues(alpha: 0.1),
                          ),
                          child: Text(t(context, 'member'), style: TextStyle(
                            color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ])),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(children: [
                    _StatPill(icon: Icons.headphones_rounded, value: '${stats.totalListens}', label: t(context, 'stat_listens'), color: AppColors.gold),
                    const SizedBox(width: 8),
                    _StatPill(icon: Icons.favorite_rounded, value: '$favCount', label: t(context, 'stat_favorites'), color: AppColors.sunset),
                    const SizedBox(width: 8),
                    _StatPill(icon: Icons.timer_outlined, value: '${stats.totalListeningMinutes}', label: t(context, 'stat_minutes'), color: AppColors.goldLight),
                  ]),

                  const SizedBox(height: 28),

                  Text(t(context, 'settings').toUpperCase(), style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                ]),
              )),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: t(context, 'notifications'),
                    color: AppColors.sky,
                    trailing: Switch.adaptive(
                      value: _notificationsOn, onChanged: _toggleNotif,
                      activeColor: AppColors.gold, activeTrackColor: AppColors.gold.withValues(alpha: 0.3),
                      inactiveTrackColor: Colors.white12, inactiveThumbColor: Colors.white30,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    label: t(context, 'language'),
                    color: AppColors.sunset,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(lp.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gold, fontSize: 12)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                    ]),
                    onTap: _showLangPicker,
                  ),
                  _SettingsTile(icon: Icons.info_outline_rounded, label: t(context, 'about'), color: AppColors.teal, onTap: _showAbout),

                  const SizedBox(height: 24),
                  Text(t(context, 'account').toUpperCase(), style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold.withValues(alpha: 0.7), fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),

                  _SettingsTile(icon: Icons.person_outline_rounded, label: t(context, 'edit_profile'), color: AppColors.lavender, onTap: _editProfile),
                  _SettingsTile(icon: Icons.lock_outline_rounded, label: t(context, 'change_password'), color: AppColors.sunset, onTap: _changePassword),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.error.withValues(alpha: 0.06),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.15), width: 0.5),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(t(context, 'logout'),
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text('MobPlay v1.0.0', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted))),
                  const SizedBox(height: 120),
                ]))),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatPill({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.18), width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.label, required this.color, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap, behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            color: AppColors.glassBg, border: Border.all(color: AppColors.glassBorder, width: 0.5)),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            trailing ?? Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ]),
        ),
      ),
    );
  }
}
