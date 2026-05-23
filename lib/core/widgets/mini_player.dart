import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/providers/player_provider.dart';
import 'package:mobplay/screens/player/full_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);
    final song = player.currentSong;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const FullPlayerScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withValues(alpha: 0.55),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        // Cover artwork with golden glow if playing
                        Hero(
                          tag: 'cover_${song.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: player.isPlaying
                                  ? [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImage(song.coverUrl, 46),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title & Reciter Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                  if (player.isPlaying) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.equalizer_rounded,
                                      color: AppColors.gold,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Premium Control Buttons
                        _ScaleOnTap(
                          onTap: () => player.togglePlayPause(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gold,
                                  AppColors.gold.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                player.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ScaleOnTap(
                          onTap: player.hasNext ? () => player.playNext() : null,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: player.hasNext
                                  ? Colors.white
                                  : AppColors.textMuted.withValues(alpha: 0.4),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  // Progress Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final dur = player.duration.inMilliseconds;
                      final pos = player.position.inMilliseconds;
                      final double width = dur > 0
                          ? (pos / dur) * constraints.maxWidth
                          : 0;
                      return Stack(
                        children: [
                          Container(
                            height: 3.0,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 3.0,
                            width: width.clamp(0, constraints.maxWidth),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: AppColors.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url, double size) {
    if (url.startsWith('asset://')) {
      final path = url.replaceFirst('asset://', '');
      return Image.asset(path,
          width: size, height: size, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: size,
        height: size,
        color: AppColors.surfaceLight,
        child: const Icon(Icons.music_note, color: Colors.white24, size: 20),
      ),
      errorWidget: (_, __, ___) => Image.asset(
        'assets/images/alafasy.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

// Tactical touch scale feedback for premium feel
class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _ScaleOnTap({required this.child, this.onTap});
  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
