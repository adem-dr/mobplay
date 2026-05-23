import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/player_provider.dart';
import 'package:mobplay/services/lyrics_service.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';

import 'package:mobplay/core/l10n/app_translations.dart';

/// Full-screen karaoke lyrics view with word-by-word highlighting.
class LyricsScreen extends StatefulWidget {
  final String surahNumber;
  final String surahName;
  final String surahNameAr;

  const LyricsScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surahNameAr,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen>
    with SingleTickerProviderStateMixin {
  List<Ayah> _ayahs = [];
  List<double> _audioWeights = [];
  List<TimedAyah> _timedAyahs = [];
  bool _isLoading = true;
  int _activeIndex = -1;
  Duration _lastKnownDuration = Duration.zero;

  final ScrollController _scrollCtrl = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _userScrolling = false;

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    try {
      // 1. Fetch text of Ayahs first (blazing fast, often cached)
      final ayahs = await LyricsService.fetchAyahs(widget.surahNumber);
      if (!mounted) return;

      setState(() {
        _ayahs = ayahs;
        for (int i = 0; i < _ayahs.length; i++) {
          _ayahKeys[i] = GlobalKey();
        }
        _isLoading = false;
        _recalcTimings(); // Calcs immediately using word-count fallback
      });

      // 2. Fetch weights in the background
      final weights = await LyricsService.fetchAyahWeights(widget.surahNumber);
      if (!mounted) return;

      setState(() {
        _audioWeights = weights;
        _recalcTimings(); // Seamlessly upgrades to precise audio timings
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _recalcTimings() {
    final player = context.read<PlayerProvider>();
    if (player.duration.inMilliseconds > 0 && _ayahs.isNotEmpty) {
      _timedAyahs = LyricsService.createTimedAyahs(
        _ayahs,
        player.duration,
        audioWeights: _audioWeights,
        surahNumber: widget.surahNumber,
      );
      _lastKnownDuration = player.duration;
    }
  }

  void _scrollToActive(int index) {
    if (_userScrolling) return;
    final key = _ayahKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.35, // position the active ayah ~35% from top
      );
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final pos = player.position;

    // Recalculate timings if duration changed
    if (player.duration != _lastKnownDuration &&
        player.duration.inMilliseconds > 0 &&
        _ayahs.isNotEmpty) {
      _recalcTimings();
    }

    // Determine active ayah
    int newActive = _activeIndex;
    if (_timedAyahs.isNotEmpty) {
      final adjustedPos = pos + const Duration(milliseconds: 250);
      for (int i = 0; i < _timedAyahs.length; i++) {
        if (adjustedPos >= _timedAyahs[i].startTime && adjustedPos < _timedAyahs[i].endTime) {
          newActive = i;
          break;
        }
        if (i == _timedAyahs.length - 1 && adjustedPos >= _timedAyahs[i].startTime) {
          newActive = i;
        }
      }
    }
    if (newActive != _activeIndex) {
      _activeIndex = newActive;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToActive(newActive));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: Stack(
        children: [
          // ── Ambient glow background ──
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.5),
                  radius: 1.5,
                  colors: [
                    AppColors.gold
                        .withValues(alpha: 0.04 * _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildLyricsList(player, pos)),
                _buildMiniControls(player, pos),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
            color: Colors.white70,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                widget.surahName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                widget.surahNameAr,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: AppColors.gold.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Ayah counter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.gold.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              '${_ayahs.length} ${t(context, 'ayahs')}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ── Lyrics list ───────────────────────────────────────────────────────────
  Widget _buildLyricsList(PlayerProvider player, Duration pos) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: 16),
            Text(t(context, 'loading_ayahs'),
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    if (_ayahs.isEmpty) {
      return Center(
        child: Text(t(context, 'no_ayahs'),
            style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        if (notif is ScrollStartNotification &&
            notif.dragDetails != null) {
          _userScrolling = true;
        } else if (notif is ScrollEndNotification) {
          Future.delayed(const Duration(seconds: 3),
              () => _userScrolling = false);
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: _timedAyahs.isEmpty ? _ayahs.length : _timedAyahs.length,
        itemBuilder: (context, index) {
          if (_timedAyahs.isEmpty) {
            // No timing info yet, show plain text
            return _buildPlainAyah(_ayahs[index], index);
          }
          return _buildTimedAyah(_timedAyahs[index], index, pos);
        },
      ),
    );
  }

  // ── Plain ayah (no timing yet) ────────────────────────────────────────────
  Widget _buildPlainAyah(Ayah ayah, int index) {
    return Padding(
      key: _ayahKeys[index],
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _buildAyahBadge(ayah.numberInSurah, false),
          const SizedBox(height: 10),
          Text(
            ayah.text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white60,
              height: 2.0,
              fontFamily: 'Amiri',
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Timed ayah with karaoke word highlighting ─────────────────────────────
  Widget _buildTimedAyah(TimedAyah timedAyah, int index, Duration pos) {
    final isActive = index == _activeIndex;
    final isPast = _activeIndex > index;

    return AnimatedContainer(
      key: _ayahKeys[index],
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 16 : 12,
        vertical: isActive ? 20 : 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.06)
            : Colors.transparent,
        border: isActive
            ? Border.all(
                color: AppColors.gold.withValues(alpha: 0.15),
                width: 1,
              )
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          _buildAyahBadge(timedAyah.ayah.numberInSurah, isActive),
          const SizedBox(height: 10),
          isActive
              ? _buildKaraokeText(timedAyah, pos)
              : Text(
                  timedAyah.ayah.text,
                  style: TextStyle(
                    fontSize: isPast ? 20 : 22,
                    color: isPast
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.5),
                    height: 2.0,
                    fontFamily: 'Amiri',
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  // ── Karaoke text: word-by-word gold highlighting ──────────────────────────
  Widget _buildKaraokeText(TimedAyah timedAyah, Duration pos) {
    final activeWordIdx = timedAyah.getActiveWordIndex(pos);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, __) => Text.rich(
        TextSpan(
          children: timedAyah.words.asMap().entries.map((entry) {
            final i = entry.key;
            final w = entry.value;
            final isWordActive = i == activeWordIdx;
            final isWordPast = i < activeWordIdx;

            return TextSpan(
              text: '${w.word} ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: isWordActive ? 28 : 24,
                fontWeight:
                    isWordActive ? FontWeight.w700 : FontWeight.w400,
                color: isWordActive
                    ? AppColors.gold
                    : isWordPast
                        ? AppColors.goldLight.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.75),
                shadows: isWordActive
                    ? [
                        Shadow(
                          color: AppColors.gold
                              .withValues(alpha: 0.6 * _glowAnim.value),
                          blurRadius: 20,
                        ),
                        Shadow(
                          color: AppColors.goldLight
                              .withValues(alpha: 0.3 * _glowAnim.value),
                          blurRadius: 40,
                        ),
                      ]
                    : null,
                height: 2.0,
              ),
            );
          }).toList(),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Ayah number badge ─────────────────────────────────────────────────────
  Widget _buildAyahBadge(int number, bool isActive) {
    final isIntro = number == 0;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.gold.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: isIntro
            ? Icon(Icons.auto_awesome, size: 14,
                color: isActive ? AppColors.gold : Colors.white38)
            : Text(
                '$number',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.gold : Colors.white38,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
      ),
    );
  }

  // ── Mini controls at the bottom ───────────────────────────────────────────
  Widget _buildMiniControls(PlayerProvider player, Duration pos) {
    final double maxMs = player.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final double curMs = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: BoxDecoration(
        color: const Color(0xF00A0A12),
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              thumbColor: AppColors.gold,
              overlayColor: AppColors.gold.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: curMs,
              max: maxMs,
              onChanged: (v) =>
                  player.seekTo(Duration(milliseconds: v.toInt())),
            ),
          ),

          // Time + controls row
          Row(
            children: [
              Text(_fmt(pos),
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()])),
              const Spacer(),
              // Previous
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 26),
                color: player.hasPrevious ? Colors.white70 : Colors.white24,
                onPressed:
                    player.hasPrevious ? () => player.playPrevious() : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 8),
              // Play/Pause
              GestureDetector(
                onTap: () => player.togglePlayPause(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Next
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 26),
                color: player.hasNext ? Colors.white70 : Colors.white24,
                onPressed: player.hasNext ? () => player.playNext() : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const Spacer(),
              Text(_fmt(player.duration),
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ],
      ),
    );
  }
}
