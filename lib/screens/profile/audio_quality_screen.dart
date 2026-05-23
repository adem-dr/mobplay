import 'package:flutter/material.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/glass_card.dart';
import 'package:mobplay/core/widgets/animated_list_item.dart';

class AudioQualityScreen extends StatefulWidget {
  const AudioQualityScreen({super.key});

  @override
  State<AudioQualityScreen> createState() => _AudioQualityScreenState();
}

class _AudioQualityScreenState extends State<AudioQualityScreen> {
  String selectedQuality = 'Normal';

  final List<Map<String, String>> qualities = [
    {'title': 'Low', 'subtitle': 'Data saver (96 kbps)'},
    {'title': 'Normal', 'subtitle': 'Standard quality (160 kbps)'},
    {'title': 'High', 'subtitle': 'High quality (320 kbps)'},
    {'title': 'Lossless', 'subtitle': 'Best audio experience (FLAC)'},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Audio Quality'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AnimatedListItem(
                index: 0,
                child: const Text('Streaming & Download', style: AppTextStyles.titleLarge),
              ),
              const SizedBox(height: 8),
              AnimatedListItem(
                index: 1,
                child: Text('Higher quality uses more data and storage.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 24),
              ...qualities.asMap().entries.map((entry) {
                int index = entry.key;
                var q = entry.value;
                bool isSelected = selectedQuality == q['title'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedListItem(
                    index: index + 2,
                    child: GestureDetector(
                      onTap: () => setState(() => selectedQuality = q['title']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [AppColors.neonCyan.withOpacity(0.2), AppColors.neonPurple.withOpacity(0.1)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          border: Border.all(
                            color: isSelected ? AppColors.neonCyan.withOpacity(0.5) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      q['title']!,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: isSelected ? AppColors.neonCyan : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(q['subtitle']!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.neonCyan),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
