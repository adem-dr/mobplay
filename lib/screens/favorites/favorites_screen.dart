import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/favorites_provider.dart';
import 'package:mobplay/providers/player_provider.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:mobplay/core/l10n/app_translations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";
  bool _isFocused = false;

  static const _numMap = {
    'un':'1','one':'1','deux':'2','two':'2','trois':'3','three':'3',
    'quatre':'4','four':'4','cinq':'5','five':'5','six':'6',
    'sept':'7','seven':'7','huit':'8','eight':'8','neuf':'9','nine':'9',
    'dix':'10','ten':'10',
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
    _searchFocusNode.addListener(() {
      setState(() {
        _isFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _normalize(String s) => s.toLowerCase()
    .replaceAll(RegExp(r"[-\s''`]"), '')
    .replaceAll(RegExp(r'[àáâãäå]'), 'a').replaceAll(RegExp(r'[èéêë]'), 'e')
    .replaceAll(RegExp(r'[ìíîï]'), 'i').replaceAll(RegExp(r'[òóôõö]'), 'o')
    .replaceAll(RegExp(r'[ùúûü]'), 'u');

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final originalList = favs.favorites;

    // Filter list based on search query
    final list = originalList.where((song) {
      if (_searchQuery.isEmpty) return true;
      
      String query = _searchQuery.trim().toLowerCase();
      
      // Clean query by removing common prefix words
      String cleanQuery = query
          .replaceAll(RegExp(r'\b(surat|sourate|sourat|sura|surah|sh|sourat|chaine)\b'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // Check number mappings for either query or cleanQuery
      if (_numMap.containsKey(query)) {
        query = _numMap[query]!;
      }
      if (_numMap.containsKey(cleanQuery)) {
        cleanQuery = _numMap[cleanQuery]!;
      }

      // Check if either is an exact match for the ID (surah number)
      if (song.id == query || (cleanQuery.isNotEmpty && song.id == cleanQuery)) {
        return true;
      }

      // If the query (or cleanQuery) is numeric, we ONLY allow an exact match for the ID (surah number)
      // This avoids "1" matching "10", "11", "21", "31", etc.
      final isQueryNumeric = RegExp(r'^\d+$').hasMatch(query);
      final isCleanQueryNumeric = RegExp(r'^\d+$').hasMatch(cleanQuery);
      if (isQueryNumeric || isCleanQueryNumeric) {
        // If numeric, it must match the ID exactly (e.g. "1" matches ID "1" only)
        return song.id == query || (cleanQuery.isNotEmpty && song.id == cleanQuery);
      }

      // Normalize fields for robust search matching (ignores hyphens, accents, spaces)
      final nQuery = _normalize(query);
      final nCleanQuery = cleanQuery.isNotEmpty ? _normalize(cleanQuery) : '';
      
      final nTitle = _normalize(song.title);
      final nArtist = _normalize(song.artist);
      final nAlbum = _normalize(song.album);

      // Direct title, artist, or album (translation) match
      if (nTitle.contains(nQuery) ||
          nArtist.contains(nQuery) ||
          nAlbum.contains(nQuery)) {
        return true;
      }

      // Clean query title, artist, or album match
      if (nCleanQuery.isNotEmpty) {
        if (nTitle.contains(nCleanQuery) ||
            nArtist.contains(nCleanQuery) ||
            nAlbum.contains(nCleanQuery)) {
          return true;
        }
      }

      return false;
    }).toList();

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Background Ambient Glows ──
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.rose.withValues(alpha: 0.08),
                      blurRadius: 100,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 120,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.06),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            // ── Main Content Scroll View ──
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // ── Premium App Header ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Glassmorphic heart badge
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.rose.withValues(alpha: 0.25),
                                      AppColors.rose.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppColors.rose.withValues(alpha: 0.3),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rose.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.rose,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t(context, 'favorites_title'),
                                      style: AppTextStyles.heading1.copyWith(
                                        fontSize: 26,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${originalList.length} ${t(context, 'surahs_saved')}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Action Buttons (Play All & Shuffle) ──
                          if (originalList.isNotEmpty) ...[
                            Row(
                              children: [
                                // Play All Button
                                Expanded(
                                  child: _ScaleOnTap(
                                    onTap: () {
                                      if (originalList.isNotEmpty) {
                                        context
                                            .read<PlayerProvider>()
                                            .playSong(originalList.first,
                                                queue: originalList);
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: AppColors.goldGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold.withValues(alpha: 0.3),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.play_arrow_rounded,
                                              color: Colors.white, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            t(context, 'play_all'),
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Shuffle Button
                                _ScaleOnTap(
                                  onTap: () {
                                    if (originalList.isNotEmpty) {
                                      final shuffled = List<SongModel>.from(originalList)..shuffle();
                                      context
                                          .read<PlayerProvider>()
                                          .playSong(shuffled.first, queue: shuffled);
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withValues(alpha: 0.05),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.08),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.shuffle_rounded,
                                      color: AppColors.textPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.white.withValues(alpha: 0.03),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: _isFocused || _searchQuery.isNotEmpty
                                      ? AppColors.gold.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.12),
                                  width: _isFocused ? 1.2 : 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                  if (_isFocused)
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 14),
                                  Icon(
                                    Icons.search_rounded,
                                    color: _isFocused || _searchQuery.isNotEmpty
                                        ? AppColors.gold
                                        : Colors.white.withValues(alpha: 0.4),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        inputDecorationTheme: const InputDecorationTheme(
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _searchCtrl,
                                        focusNode: _searchFocusNode,
                                        textAlignVertical: TextAlignVertical.center,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14.5,
                                          letterSpacing: 0.2,
                                        ),
                                        cursorColor: AppColors.gold,
                                        decoration: InputDecoration(
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          hintText: t(context, 'search_hint') ??
                                              "Rechercher une sourate...",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty) ...[
                                    GestureDetector(
                                      onTap: () {
                                        _searchCtrl.clear();
                                        _searchFocusNode.unfocus();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.08),
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: Colors.white.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ] else
                                    const SizedBox(width: 14),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // ── Empty / No Results State ──
                  if (list.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 80, horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Beautiful glassmorphic illustration
                            _AnimatedEmptyGlow(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.rose.withValues(alpha: 0.15),
                                      AppColors.rose.withValues(alpha: 0.03),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppColors.rose.withValues(alpha: 0.18),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rose
                                          .withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off_rounded
                                      : Icons.favorite_border_rounded,
                                  color: AppColors.rose.withValues(alpha: 0.6),
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "Aucun résultat trouvé"
                                  : t(context, 'no_favorites'),
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? "Essayez de taper un autre nom de sourate ou de récitateur."
                                  : t(context, 'no_favorites_desc'),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                height: 1.5,
                                fontSize: 12.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )

                  // ── Premium Favorites List ──
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = list[index];
                            final isPlaying =
                                context.watch<PlayerProvider>().currentSong?.id ==
                                    song.id;
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration:
                                  Duration(milliseconds: 300 + index * 50),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, child) => Transform.translate(
                                offset: Offset(0, 20 * (1 - v)),
                                child: Opacity(opacity: v, child: child),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Dismissible(
                                  key: ValueKey(song.id),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) =>
                                      favs.removeFavorite(song.id),
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.error.withValues(alpha: 0.18)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.error
                                            .withValues(alpha: 0.25),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  child: _FavoriteTile(
                                    song: song,
                                    isPlaying: isPlaying,
                                    index: index + 1,
                                    queue: list,
                                    onRemove: () =>
                                        favs.removeFavorite(song.id),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: list.length,
                        ),
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

// ── Interactive Glass Favorite Tile ──────────────────────────────────────────
class _FavoriteTile extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final int index;
  final List<SongModel> queue;
  final VoidCallback onRemove;

  const _FavoriteTile({
    required this.song,
    required this.isPlaying,
    required this.index,
    required this.queue,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _ScaleOnTap(
      onTap: () => context.read<PlayerProvider>().playSong(song, queue: queue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isPlaying
              ? AppColors.gold.withValues(alpha: 0.10)
              : AppColors.glassBg,
          border: Border.all(
            color: isPlaying
                ? AppColors.gold.withValues(alpha: 0.28)
                : AppColors.glassBorder,
            width: 0.8,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.05),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Always Visible Premium Index Bubble
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPlaying
                      ? [
                          AppColors.goldLight,
                          AppColors.gold,
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isPlaying
                      ? AppColors.goldLight
                      : AppColors.gold.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPlaying
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: TextStyle(
                    color: isPlaying ? Colors.black : AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Artwork with custom overlay if playing
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    children: [
                      _img(song.coverUrl, 52),
                      if (isPlaying)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: const Center(
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Artist Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: isPlaying ? AppColors.gold : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPlaying) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.gold,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Premium Interactive Heart Button always visible on the side
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.rose.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.rose.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.rose,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _img(String url, double s) {
    if (url.startsWith('asset://')) {
      return Image.asset(
        url.replaceFirst('asset://', ''),
        width: s,
        height: s,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      width: s,
      height: s,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/alafasy.png',
        width: s,
        height: s,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ── Interactive Click Feedback (Pulsing / Scaling) ─────────────────────────
class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ScaleOnTap({required this.child, required this.onTap});

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ── Floating Animated Heart Illustration for Empty State ─────────────────
class _AnimatedEmptyGlow extends StatefulWidget {
  final Widget child;
  const _AnimatedEmptyGlow({required this.child});

  @override
  State<_AnimatedEmptyGlow> createState() => _AnimatedEmptyGlowState();
}

class _AnimatedEmptyGlowState extends State<_AnimatedEmptyGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(
        scale: _pulse.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}
