import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/glass_card.dart';
import 'package:mobplay/core/widgets/animated_list_item.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool pushEnabled = true;
  bool newReleases = true;
  bool artistUpdates = false;
  bool emailNews = false;

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.neonCyan,
            activeTrackColor: AppColors.neonCyan.withOpacity(0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AnimatedListItem(
                index: 0,
                child: const Text('Push Notifications', style: AppTextStyles.titleLarge),
              ),
              const SizedBox(height: 16),
              AnimatedListItem(
                index: 1,
                child: _buildSwitchItem(
                  'Allow Push Notifications',
                  'Receive alerts on your device.',
                  pushEnabled,
                  (v) => setState(() => pushEnabled = v),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedListItem(
                index: 2,
                child: const Text('Updates & Offers', style: AppTextStyles.titleLarge),
              ),
              const SizedBox(height: 16),
              AnimatedListItem(
                index: 3,
                child: _buildSwitchItem(
                  'New Releases',
                  'When new albums or surahs are available.',
                  newReleases,
                  (v) => setState(() => newReleases = v),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 4,
                child: _buildSwitchItem(
                  'Artist Updates',
                  'News about artists you follow.',
                  artistUpdates,
                  (v) => setState(() => artistUpdates = v),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 5,
                child: _buildSwitchItem(
                  'Email Newsletters',
                  'Receive promotional emails and updates.',
                  emailNews,
                  (v) => setState(() => emailNews = v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
