import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobplay/providers/auth_provider.dart';
import 'package:mobplay/providers/song_provider.dart';
import 'package:mobplay/providers/player_provider.dart';
import 'package:mobplay/providers/favorites_provider.dart';
import 'package:mobplay/providers/stats_provider.dart';
import 'package:mobplay/services/prayer_times_service.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/core/widgets/animated_bubble_background.dart';
import 'package:mobplay/core/widgets/animated_list_item.dart';
import 'package:mobplay/core/widgets/custom_toast.dart';
import 'package:mobplay/core/widgets/prayer_icon.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:mobplay/core/l10n/locale_provider.dart';
import 'package:mobplay/core/l10n/app_translations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchVisible = false;
  bool _isFocused = false;
  String _query = '';

  static const _numMap = {
    'un':'1','one':'1','deux':'2','two':'2','trois':'3','three':'3',
    'quatre':'4','four':'4','cinq':'5','five':'5','six':'6',
    'sept':'7','seven':'7','huit':'8','eight':'8','neuf':'9','nine':'9',
    'dix':'10','ten':'10',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SongProvider>().loadTrending());
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim()));
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

  List<SongModel> _filter(List<SongModel> all) {
    if (_query.isEmpty) return all;
    String q = _query.toLowerCase().trim();
    if (_numMap.containsKey(q)) q = _numMap[q]!;
    if (int.tryParse(q) != null) return all.where((s) => s.id == q).toList();
    final nq = _normalize(q);
    return all.where((s) => _normalize(s.title).contains(nq) ||
        _normalize(s.artist).contains(nq) || _normalize(s.album).contains(nq)).toList();
  }

  String _getGreeting(BuildContext ctx) {
    final h = DateTime.now().hour;
    if (h < 5) return t(ctx, 'greeting_night');
    if (h < 12) return t(ctx, 'greeting_morning');
    if (h < 18) return t(ctx, 'greeting_afternoon');
    return t(ctx, 'greeting_evening');
  }

  PrayerIconType _mapIconType(IconType t) {
    switch (t) {
      case IconType.fajr: return PrayerIconType.fajr;
      case IconType.sunrise: return PrayerIconType.sunrise;
      case IconType.dhuhr: return PrayerIconType.dhuhr;
      case IconType.asr: return PrayerIconType.asr;
      case IconType.maghrib: return PrayerIconType.maghrib;
      case IconType.isha: return PrayerIconType.isha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final songs = context.watch<SongProvider>();
    final prayerService = context.watch<PrayerTimesService>();
    final stats = context.watch<StatsProvider>();
    final favCount = context.watch<FavoritesProvider>().favorites.length;
    context.watch<LocaleProvider>();
    final filtered = _filter(songs.trendingSongs);
    final isSearching = _query.isNotEmpty;

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
                  // ── Header row ──
                  AnimatedListItem(index: 0, child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_getGreeting(context), style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gold.withValues(alpha: 0.7), fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(user?.displayName ?? t(context, 'guest'),
                        style: AppTextStyles.heading1.copyWith(fontSize: 26)),
                    ])),
                    GestureDetector(
                      onTap: () {
                        setState(() { 
                          _searchVisible = !_searchVisible; 
                          if (!_searchVisible) {
                            _searchCtrl.clear(); 
                            _searchFocusNode.unfocus();
                          } else {
                            _searchFocusNode.requestFocus();
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250), width: 42, height: 42,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                          color: _searchVisible ? AppColors.gold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(color: _searchVisible ? AppColors.gold.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08), width: 0.5)),
                        child: Icon(_searchVisible ? Icons.close : Icons.search,
                          color: _searchVisible ? AppColors.gold : Colors.white54, size: 20),
                      ),
                    ),
                  ])),

                  // ── Premium Search Bar (animated slide) ──
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _searchVisible
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0xFF16151A), // Unified solid dark background
                                border: Border.all(
                                  color: _isFocused || _query.isNotEmpty
                                      ? AppColors.gold.withValues(alpha: 0.5)
                                      : AppColors.gold.withValues(alpha: 0.15),
                                  width: _isFocused ? 1.5 : 1.0,
                                ),
                                boxShadow: [
                                  if (_isFocused)
                                    BoxShadow(
                                      color: AppColors.gold.withValues(alpha: 0.1),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.search_rounded,
                                    color: _isFocused || _query.isNotEmpty ? AppColors.gold : Colors.white38,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                        cursorColor: AppColors.gold,
                                        cursorWidth: 2,
                                        cursorRadius: const Radius.circular(2),
                                        decoration: InputDecoration(
                                          hintText: t(context, 'search_hint'),
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.3),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_query.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchCtrl.clear();
                                        _searchFocusNode.requestFocus();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.08),
                                        ),
                                        child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.7), size: 16),
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 16),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // ── Search results count badge ──
                  if (isSearching) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.gold.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_stories_rounded,
                            color: AppColors.gold, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${filtered.length} ${t(context, 'results_found')}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Prayer card ──
                  if (!isSearching && prayerService.nextPrayer != null) ...[
                    const SizedBox(height: 20),
                    AnimatedListItem(index: 1, child: _PrayerCard(
                      service: prayerService,
                      mapIcon: _mapIconType,
                    )),
                  ],

                  // ── Quick stats row — warm gold/amber tones only ──
                  if (!isSearching) ...[
                    const SizedBox(height: 16),
                    AnimatedListItem(index: 2, child: Row(children: [
                      _QuickStat(
                        icon: Icons.headphones_rounded,
                        label: t(context, 'stat_listens'),
                        value: '${stats.totalListens}',
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 10),
                      _QuickStat(
                        icon: Icons.favorite_rounded,
                        label: t(context, 'stat_favorites'),
                        value: '$favCount',
                        color: AppColors.sunset,
                      ),
                      const SizedBox(width: 10),
                      _QuickStat(
                        icon: Icons.auto_stories_rounded,
                        label: t(context, 'stat_surahs'),
                        value: '${songs.trendingSongs.length}',
                        color: AppColors.goldLight,
                      ),
                    ])),
                  ],

                  const SizedBox(height: 22),
                  Text(isSearching ? t(context, 'results_found') : t(context, 'all_surahs'), style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                ]),
              )),

              // ── Surah list ──
              if (songs.isLoading)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold))))
              else if (filtered.isEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Column(children: [
                    Icon(Icons.search_off, color: Colors.white.withValues(alpha: 0.15), size: 48),
                    const SizedBox(height: 14),
                    Text(isSearching ? '"$_query"' : t(context, 'all_surahs'),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
                  ])))
              else
                SliverPadding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                    final song = filtered[index];
                    final isPlaying = context.watch<PlayerProvider>().currentSong?.id == song.id;
                    return _SurahTile(song: song, index: index, isPlaying: isPlaying, queue: songs.trendingSongs);
                  }, childCount: filtered.length))),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Prayer Card — warm beige/cream tones matching the mosque ────────────────
class _PrayerCard extends StatelessWidget {
  final PrayerTimesService service;
  final PrayerIconType Function(IconType) mapIcon;
  const _PrayerCard({required this.service, required this.mapIcon});

  @override
  Widget build(BuildContext context) {
    final next = service.nextPrayer;
    if (next == null) return const SizedBox.shrink();

    final accent = _getAccent(next.iconType);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2418).withValues(alpha: 0.9),
            const Color(0xFF1E1A14).withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD4A052).withValues(alpha: 0.18),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrayerIcon(type: PrayerIconType.moon, size: 10, color: accent),
                    const SizedBox(width: 5),
                    Text(t(context, 'next_prayer').toUpperCase(), style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: accent, letterSpacing: 1.2,
                    )),
                  ],
                ),
              ),
              const Spacer(),
              if (service.hijriDate.isNotEmpty)
                Text(
                  '${service.hijriDate} ${service.hijriMonth}',
                  style: TextStyle(
                    fontSize: 10, color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Main row
          Row(
            children: [
              // Prayer icon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.15),
                      accent.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: PrayerIcon(
                    type: mapIcon(next.iconType),
                    size: 24,
                    color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name (FR + Arabic)
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(context, next.name.toLowerCase()), style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w700, fontSize: 20,
                    color: const Color(0xFFF5EDE0),
                  )),
                  if (context.read<LocaleProvider>().locale != 'ar') ...[
                    const SizedBox(height: 2),
                    Text(next.nameAr, style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: accent.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    )),
                  ],
                ],
              )),

              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(next.time, style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE8C078),
                    fontFeatures: const [FontFeature.tabularFigures()],
                    height: 1.0,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted, size: 10),
                      const SizedBox(width: 3),
                      Text(service.city, style: TextStyle(
                        fontSize: 10, color: AppColors.textMuted,
                      )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAccent(IconType type) {
    switch (type) {
      case IconType.fajr: return const Color(0xFFB8A9D4);
      case IconType.sunrise: return const Color(0xFFE8B76C);
      case IconType.dhuhr: return const Color(0xFFD4A052);
      case IconType.asr: return const Color(0xFFE8C078);
      case IconType.maghrib: return const Color(0xFFD4876C);
      case IconType.isha: return const Color(0xFFCBB89D);  // warm beige — NOT blue
    }
  }
}

// ── Quick Stat pill — warm palette ──────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _QuickStat({
    required this.icon, required this.label,
    required this.value, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: Colors.white, fontFeatures: [FontFeature.tabularFigures()],
            )),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Surah Tile ───────────────────────────────────────────────────────────────
class _SurahTile extends StatelessWidget {
  final SongModel song;
  final int index;
  final bool isPlaying;
  final List<SongModel> queue;
  const _SurahTile({required this.song, required this.index, required this.isPlaying, required this.queue});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => context.read<PlayerProvider>().playSong(song, queue: queue),
        child: AnimatedContainer(duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            color: isPlaying ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
            border: isPlaying ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1) : null),
          child: Row(children: [
            // Surah number
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? AppColors.gold.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: isPlaying ? AppColors.gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.25)),
              ),
              child: Center(child: Text(song.id,
                style: TextStyle(color: isPlaying ? AppColors.gold : Colors.white, fontSize: 14,
                  fontWeight: FontWeight.bold, fontFeatures: const [FontFeature.tabularFigures()]),
                textAlign: TextAlign.center)),
            ),
            const SizedBox(width: 12),
            ClipRRect(borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 48, height: 48, child: _buildImg(song.coverUrl, 48))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(song.title, style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600, color: isPlaying ? AppColors.gold : AppColors.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(song.artist, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 8),
            Consumer<FavoritesProvider>(builder: (ctx, favs, _) {
              final isFav = favs.isFavorite(song.id);
              return GestureDetector(
                onTap: () { if (isFav) { favs.removeFavorite(song.id); } else { favs.addFavorite(song); CustomToast.show(ctx, t(ctx, 'added_to_favorites'), icon: Icons.favorite); } },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFav ? AppColors.sunset.withValues(alpha: 0.12) : Colors.transparent,
                  ),
                  child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? AppColors.sunset : Colors.white24, size: 18)),
              );
            }),
            const SizedBox(width: 4),
            if (isPlaying)
              const _PlayingIndicator()
            else
              Icon(Icons.play_arrow_rounded, color: Colors.white.withValues(alpha: 0.2), size: 22),
          ]),
        ),
      ),
    );
  }

  static Widget _buildImg(String url, double size) {
    if (url.startsWith('asset://')) return Image.asset(url.replaceFirst('asset://', ''), width: size, height: size, fit: BoxFit.cover);
    return Image.network(url, width: size, height: size, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/alafasy.png', width: size, height: size, fit: BoxFit.cover));
  }
}

// ── Animated playing indicator ────────────────────────────────────────────────
class _PlayingIndicator extends StatefulWidget {
  const _PlayingIndicator();
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 28,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            final offset = i * 0.2;
            final barH = 8.0 + 10.0 * (((_ctrl.value + offset) % 1.0) * 0.6 + 0.4 * (i == 1 ? 1 : 0.7));
            return Container(
              width: 3, height: barH,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: AppColors.goldGradient,
              ),
            );
          }),
        ),
      ),
    );
  }
}
