import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobplay/core/theme/app_colors.dart';
import 'package:mobplay/core/theme/app_text_styles.dart';
import 'package:mobplay/models/adkar_model.dart';
import 'package:mobplay/core/l10n/app_translations.dart';

class AdkarDetailScreen extends StatefulWidget {
  final String title;
  final String titleAr;
  final Color glowColor;
  final List<AdkarItem> adkarList;

  const AdkarDetailScreen({
    super.key,
    required this.title,
    required this.titleAr,
    required this.glowColor,
    required this.adkarList,
  });

  @override
  State<AdkarDetailScreen> createState() => _AdkarDetailScreenState();
}

class _AdkarDetailScreenState extends State<AdkarDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<int> _currentCounts;
  bool _showTranslations = true;

  @override
  void initState() {
    super.initState();
    _currentCounts = List<int>.filled(widget.adkarList.length, 0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _incrementCount(int index) {
    if (_currentCounts[index] < widget.adkarList[index].countTarget) {
      setState(() {
        _currentCounts[index]++;
      });
      
      // Dynamic Haptics
      if (_currentCounts[index] == widget.adkarList[index].countTarget) {
        HapticFeedback.vibrate(); // Strong celebration rumble on completion
      } else {
        HapticFeedback.selectionClick(); // Satisfying clean tick
      }
    }
  }

  void _resetCount(int index) {
    setState(() {
      _currentCounts[index] = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _resetAll() {
    setState(() {
      _currentCounts = List<int>.filled(widget.adkarList.length, 0);
    });
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t(context, 'all_adkar_reset')),
        backgroundColor: widget.glowColor.withValues(alpha: 0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtered list based on search query
    final List<MapEntry<int, AdkarItem>> indexedFilteredList = widget.adkarList
        .asMap()
        .entries
        .where((entry) {
          final item = entry.value;
          final query = _searchQuery.toLowerCase();
          return item.arabic.toLowerCase().contains(query) ||
              item.translation.toLowerCase().contains(query) ||
              item.transliteration.toLowerCase().contains(query) ||
              item.source.toLowerCase().contains(query);
        })
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient light
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              key: const ValueKey('ambient_glow'),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.glowColor.withValues(alpha: 0.04),
              ),
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Sliver App Bar
              SliverAppBar(
                backgroundColor: AppColors.background,
                expandedHeight: 180,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                 actions: [
                  IconButton(
                    icon: Icon(
                      _showTranslations ? Icons.g_translate_rounded : Icons.translate_rounded,
                      color: _showTranslations ? widget.glowColor : Colors.white60,
                      size: 22,
                    ),
                    tooltip: t(context, 'show_translations'),
                    onPressed: () {
                      setState(() {
                        _showTranslations = !_showTranslations;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white60, size: 24),
                    tooltip: t(context, 'reset_all'),
                    onPressed: _resetAll,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.titleAr,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.glowColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar with a clean glassmorphism aesthetic
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF14161C),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
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
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: t(context, 'search_invocation'),
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: widget.glowColor, size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white60, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Adkar Cards List
              indexedFilteredList.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          t(context, 'no_invocation_found'),
                          style: const TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = indexedFilteredList[index];
                            final int originalIndex = entry.key;
                            final AdkarItem item = entry.value;
                            final int count = _currentCounts[originalIndex];
                            final bool isCompleted = count == item.countTarget;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: AdkarCardWidget(
                                item: item,
                                count: count,
                                isCompleted: isCompleted,
                                glowColor: widget.glowColor,
                                onTap: () => _incrementCount(originalIndex),
                                onReset: () => _resetCount(originalIndex),
                                showTranslations: _showTranslations,
                              ),
                            );
                          },
                          childCount: indexedFilteredList.length,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TapBubble {
  final Offset position;
  final double id;
  _TapBubble(this.position, this.id);
}

class AdkarCardWidget extends StatefulWidget {
  final AdkarItem item;
  final int count;
  final bool isCompleted;
  final Color glowColor;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final bool showTranslations;

  const AdkarCardWidget({
    super.key,
    required this.item,
    required this.count,
    required this.isCompleted,
    required this.glowColor,
    required this.onTap,
    required this.onReset,
    required this.showTranslations,
  });

  @override
  State<AdkarCardWidget> createState() => _AdkarCardWidgetState();
}

class _AdkarCardWidgetState extends State<AdkarCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Track floating "+1" bubbles
  final List<_TapBubble> _bubbles = [];
  double _bubbleIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.97,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details) {
    _controller.forward();
    widget.onTap();
    
    // Do not show "+1" if already completed
    if (widget.isCompleted) return;

    final localPos = details.localPosition;
    setState(() {
      _bubbleIdCounter++;
      final id = _bubbleIdCounter;
      _bubbles.add(_TapBubble(localPos, id));

      // Clean up bubble after slide animation
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _bubbles.removeWhere((b) => b.id == id);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: widget.isCompleted ? const Color(0xFF0F1C15) : const Color(0xFF14161C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.05),
            width: widget.isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (widget.isCompleted)
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: -2,
              )
            else
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.03),
                blurRadius: 15,
                spreadRadius: -2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Real touch gesture listener (entire card is interactive and registers immediately)
                GestureDetector(
                  onTapDown: (_) => _controller.reverse(),
                  onTapUp: _handleTap,
                  onTapCancel: () => _controller.forward(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top row with source and utilities (Copy, Reset)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.source,
                                style: TextStyle(
                                  color: widget.glowColor.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Top right buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Copy Text Button
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                      text: '${widget.item.arabic}\n\n${widget.item.translation}'
                                    ));
                                    HapticFeedback.mediumImpact();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(t(context, 'invocation_copied')),
                                        backgroundColor: AppColors.gold,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Icon(Icons.copy_rounded, size: 18, color: Colors.white38),
                                  ),
                                ),
                                
                                // Undo individual progress button
                                if (widget.count > 0) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: widget.onReset,
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      child: Icon(Icons.undo_rounded, size: 18, color: Colors.white38),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Arabic text (standard Text used instead of SelectableText to fix touch-swallowing bug!)
                        Text(
                          widget.item.arabic,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 25,
                            height: 1.8,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Translations panel
                        if (widget.showTranslations) ...[
                          const SizedBox(height: 18),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          const SizedBox(height: 14),
                          Text(
                            widget.item.transliteration,
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.item.translation,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ],

                        // Interactive Progress Bar (designed using LayoutBuilder to be fully responsive)
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double fraction = widget.count / widget.item.countTarget;
                            final double width = fraction * constraints.maxWidth;
                            
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 5,
                                    width: double.infinity,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 5,
                                    width: width.clamp(0.0, constraints.maxWidth),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: widget.isCompleted
                                            ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                                            : [widget.glowColor.withValues(alpha: 0.8), widget.glowColor],
                                      ),
                                      boxShadow: [
                                        if (widget.count > 0)
                                          BoxShadow(
                                            color: (widget.isCompleted ? const Color(0xFF10B981) : widget.glowColor).withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Bottom row showing targets and the stylized counter bubble
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Objectif details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Objectif',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.item.countTarget} Répétition${widget.item.countTarget > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Beautiful counter button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 90,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  colors: widget.isCompleted
                                      ? [const Color(0xFF065F46), const Color(0xFF059669)]
                                      : [
                                          widget.glowColor.withValues(alpha: 0.16),
                                          widget.glowColor.withValues(alpha: 0.04)
                                        ],
                                ),
                                border: Border.all(
                                  color: widget.isCompleted ? const Color(0xFF10B981) : widget.glowColor.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  if (widget.isCompleted)
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: -2,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.isCompleted)
                                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18)
                                    else ...[
                                      Text(
                                        '${widget.count}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '/${widget.item.countTarget}',
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Floating interactive "+1" indicators
                ..._bubbles.map((bubble) {
                  return Positioned(
                    left: bubble.position.dx - 22,
                    top: bubble.position.dy - 35,
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          final double translateY = -45.0 * value;
                          final double opacity = 1.0 - value;
                          final double scale = 0.9 + (value * 0.3);
                          
                          return Transform.translate(
                            offset: Offset(0, translateY),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.glowColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.glowColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '+1',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
