import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/glass_card.dart';
import 'package:mobplay/core/widgets/animated_list_item.dart';

class DownloadsSettingsScreen extends StatefulWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  State<DownloadsSettingsScreen> createState() => _DownloadsSettingsScreenState();
}

class _DownloadsSettingsScreenState extends State<DownloadsSettingsScreen> {
  bool wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Downloads'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AnimatedListItem(
                index: 0,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Download over Wi-Fi only', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 4),
                            Text('Save cellular data.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: wifiOnly,
                        onChanged: (v) => setState(() => wifiOnly = v),
                        activeColor: AppColors.neonCyan,
                        activeTrackColor: AppColors.neonCyan.withOpacity(0.3),
                        inactiveThumbColor: AppColors.textMuted,
                        inactiveTrackColor: AppColors.surfaceLight,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedListItem(
                index: 1,
                child: const Text('Storage Usage', style: AppTextStyles.titleLarge),
              ),
              const SizedBox(height: 16),
              AnimatedListItem(
                index: 2,
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('MobPlay Data', style: AppTextStyles.bodyMedium),
                          Text('1.2 GB', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neonCyan, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: 0.15,
                          minHeight: 12,
                          backgroundColor: AppColors.background.withOpacity(0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('64 GB Free Space', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedListItem(
                index: 3,
                child: GlassCard(
                  padding: const EdgeInsets.all(4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared successfully.')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: AppColors.error),
                          const SizedBox(width: 16),
                          Expanded(child: Text('Clear Cache', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error))),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
