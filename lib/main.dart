import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/song_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/biometric_service.dart';
import 'services/prayer_times_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/player/full_player_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/prayer/prayer_times_screen.dart';
import 'screens/adkar/adkar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'core/widgets/mini_player.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/l10n/locale_provider.dart';
import 'core/l10n/app_translations.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mobplay.app.channel.audio',
    androidNotificationChannelName: 'Lecteur Audio',
    androidNotificationOngoing: true,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set system UI style for iOS feel
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MobPlayApp());
}

class MobPlayApp extends StatelessWidget {
  const MobPlayApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => SongProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => PrayerTimesService()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: MaterialApp(
          title: 'MobPlay',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: const _Router(),
        ),
      );
}

class _Router extends StatefulWidget {
  const _Router();
  @override
  State<_Router> createState() => _RouterState();
}

class _RouterState extends State<_Router> {
  bool _splashDone = false;
  bool _checking = true;
  bool _biometricPassed = false;
  final BiometricService _bio = BiometricService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the mosque background image during splash
    precacheImage(const AssetImage('assets/images/mosque_bg.png'), context);
  }

  void _onSplashDone() {
    setState(() => _splashDone = true);
    _initApp();
  }

  Future<void> _initApp() async {
    bool authSuccess = await _bio.authenticate();
    if (authSuccess) {
      setState(() => _biometricPassed = true);
      // ignore: use_build_context_synchronously
      await context.read<AuthProvider>().checkAuth();
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(onDone: _onSplashDone);
    }

    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    if (!_biometricPassed) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fingerprint,
                    size: 42, color: AppColors.gold),
              ),
              const SizedBox(height: 20),
              const Text('Authentification requise',
                  style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text('Utilisez votre empreinte pour continuer',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  setState(() => _checking = true);
                  _initApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
                child: const Text('Réessayer'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _biometricPassed = true;
                    _checking = false;
                  });
                },
                child: const Text(
                  'Se connecter par e-mail / mot de passe',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (_, a, __) => a.loggedIn ? const _StatsWiring(child: _Main()) : const LoginScreen(),
    );
  }
}

class _Main extends StatefulWidget {
  const _Main();
  @override
  State<_Main> createState() => _MainState();
}

// Wire stats tracking into the player provider
class _StatsWiring extends StatelessWidget {
  final Widget child;
  const _StatsWiring({required this.child});
  @override
  Widget build(BuildContext context) {
    // Inject stats provider reference into player provider
    final player = context.read<PlayerProvider>();
    final stats = context.read<StatsProvider>();
    player.setStatsProvider(stats);
    return child;
  }
}

class _MainState extends State<_Main> {
  int _idx = 0;

  // Keep screens alive with keys to avoid rebuilds
  static const List<Widget> _screens = [
    DashboardScreen(),
    PrayerTimesScreen(),
    AdkarScreen(),
    FavoritesScreen(),
    FullPlayerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch locale so nav labels update on language change
    context.watch<LocaleProvider>();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _idx, children: _screens),
          ),
          // MiniPlayer only if not on the full player tab
          if (_idx != 4) const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.mosque_outlined,
        'activeIcon': Icons.mosque,
        'labelKey': 'nav_home',
      },
      {
        'icon': Icons.schedule_outlined,
        'activeIcon': Icons.schedule,
        'labelKey': 'nav_prayer',
      },
      {
        'icon': Icons.auto_stories_outlined,
        'activeIcon': Icons.auto_stories,
        'labelKey': 'nav_adkar',
      },
      {
        'icon': Icons.favorite_outline,
        'activeIcon': Icons.favorite,
        'labelKey': 'nav_favorites',
      },
      {
        'icon': Icons.play_circle_outline,
        'activeIcon': Icons.play_circle,
        'labelKey': 'nav_player',
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'labelKey': 'nav_profile',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF20B0B0F), // Deeper, premium glass dark background
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                children: [
                  // Animated sliding background capsule centered perfectly behind active icon
                  Positioned(
                    top: 4,
                    left: 0,
                    right: 0,
                    height: 38, // Matches the exact height of the icon container
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment(
                        -1.0 + (_idx * (2.0 / (items.length - 1))),
                        0.0, // Centered vertically in the icon row
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / items.length,
                        child: Center(
                          child: Container(
                            width: 42,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gold.withValues(alpha: 0.15),
                                  AppColors.gold.withValues(alpha: 0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.25),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Row of interactive navigation items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = _idx == index;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_idx != index) {
                              setState(() => _idx = index);
                              HapticFeedback.selectionClick();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon container (height matches the indicator capsule perfectly)
                              SizedBox(
                                height: 38,
                                child: Center(
                                  child: AnimatedScale(
                                    scale: isSelected ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      isSelected ? item['activeIcon'] : item['icon'],
                                      color: isSelected ? AppColors.gold : AppColors.textMuted,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              // Text label underneath
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 7.0,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppColors.gold : AppColors.textMuted,
                                  letterSpacing: isSelected ? 0.1 : 0.0,
                                ),
                                child: Text(
                                  t(context, item['labelKey']),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
