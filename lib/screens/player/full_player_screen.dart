import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/player_provider.dart';
import 'package:mobplay/providers/favorites_provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/custom_toast.dart';
import 'package:mobplay/core/l10n/app_translations.dart';
import 'package:mobplay/screens/player/lyrics_screen.dart';

class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});
  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _discCtrl;

  @override
  void initState() {
    super.initState();
    // Slower rotation = smoother visual (30s per full rotation)
    _discCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _discCtrl.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;

    if (song == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.music_off_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(t(context, 'no_audio_playing'), style: AppTextStyles.subtitle),
        ])),
      );
    }

    // Control disc rotation based on play state
    if (player.isPlaying) {
      if (!_discCtrl.isAnimating) _discCtrl.repeat();
    } else {
      _discCtrl.stop();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        // ── Static gradient background — zero per-frame cost ──
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.3),
              radius: 1.2,
              colors: [
                AppColors.gold.withValues(alpha: 0.05),
                AppColors.background,
                AppColors.background,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Content
        SafeArea(child: Column(children: [
          // App bar
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                color: Colors.white70, onPressed: () => Navigator.maybePop(context)),
              const Spacer(),
              Text(t(context, 'en_lecture'), style: AppTextStyles.caption.copyWith(
                letterSpacing: 2, color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 10)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.more_horiz, size: 24),
                color: Colors.white70, onPressed: () {}),
            ])),

          const Spacer(flex: 2),

          // ── Disc — uses RotationTransition (hardware-composited layer) ──
          RepaintBoundary(
            child: RotationTransition(
              turns: _discCtrl,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.08),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildImg(song.coverUrl, 260)),
              ),
            ),
          ),

          const Spacer(),

          // Title
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(children: [
              Text(song.title, style: AppTextStyles.heading2.copyWith(fontSize: 24),
                textAlign: TextAlign.center, maxLines: 2),
              const SizedBox(height: 6),
              Text(song.artist, style: AppTextStyles.subtitle.copyWith(
                color: AppColors.gold.withValues(alpha: 0.7), fontSize: 14),
                textAlign: TextAlign.center),
            ])),

          const SizedBox(height: 32),

          // Progress
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              SliderTheme(data: Theme.of(context).sliderTheme,
                child: Slider(
                  value: player.position.inMilliseconds.toDouble().clamp(
                    0, player.duration.inMilliseconds.toDouble().clamp(1, double.infinity)),
                  max: player.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                  onChanged: (v) => player.seekTo(Duration(milliseconds: v.toInt())))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_fmt(player.position), style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted, fontSize: 11)),
                  Text(_fmt(player.duration), style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted, fontSize: 11)),
                ])),
            ])),

          const SizedBox(height: 20),

          // Controls
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              IconButton(icon: const Icon(Icons.shuffle_rounded, size: 22),
                color: AppColors.textMuted, onPressed: () {}),
              IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 34),
                color: player.hasPrevious ? Colors.white : AppColors.textMuted,
                onPressed: player.hasPrevious ? () => player.playPrevious() : null),
              // Play/Pause
              GestureDetector(
                onTap: () => player.togglePlayPause(),
                child: Container(width: 68, height: 68,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient,
                    boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)]),
                  child: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                    child: Icon(player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(player.isPlaying), color: Colors.white, size: 34)))),
              IconButton(icon: const Icon(Icons.skip_next_rounded, size: 34),
                color: player.hasNext ? Colors.white : AppColors.textMuted,
                onPressed: player.hasNext ? () => player.playNext() : null),
              IconButton(icon: Icon(
                player.isRepeat ? Icons.repeat_one_rounded : Icons.repeat_rounded, size: 22),
                color: player.isRepeat ? AppColors.gold : AppColors.textMuted,
                onPressed: () => player.toggleRepeat()),
            ])),

          const SizedBox(height: 20),

          // Bottom actions
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Consumer<FavoritesProvider>(builder: (ctx, favs, _) {
                final isFav = favs.isFavorite(song.id);
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border_rounded, size: 24),
                  color: isFav ? AppColors.rose : AppColors.textMuted,
                  onPressed: () {
                    if (isFav) {
                      favs.removeFavorite(song.id);
                    } else {
                      favs.addFavorite(song);
                      CustomToast.show(ctx, t(ctx, 'added_to_favorites'));
                    }
                  },
                );
              }),
              // ── Karaoke Lyrics Button ──
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LyricsScreen(
                        surahNumber: song.id,
                        surahName: song.title,
                        surahNameAr: song.artist,
                      ),
                      transitionsBuilder: (_, anim, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.2),
                        AppColors.gold.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lyrics_outlined, color: AppColors.gold, size: 18),
                      const SizedBox(width: 6),
                      Text(t(context, 'lyrics'), style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.share_outlined, size: 22),
                color: AppColors.textMuted, onPressed: () {}),
              IconButton(icon: const Icon(Icons.queue_music_outlined, size: 22),
                color: AppColors.textMuted, onPressed: () {}),
            ])),

          const Spacer(),
        ])),
      ]),
    );
  }

  static Widget _buildImg(String url, double size) {
    if (url.startsWith('asset://')) {
      return Image.asset(url.replaceFirst('asset://', ''),
        width: size, height: size, fit: BoxFit.cover);
    }
    return Image.network(url, width: size, height: size, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/alafasy.png',
        width: size, height: size, fit: BoxFit.cover));
  }
}
