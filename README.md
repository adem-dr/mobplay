<h1 align="center">
  <br>
  🕌 MobPlay
  <br>
</h1>

<p align="center">
  <b>A premium Islamic audio streaming & spiritual companion app</b><br>
  Built with Flutter · Firebase · Just Audio
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=android" />
  <img src="https://img.shields.io/badge/Version-1.0.0-gold" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
</p>

---

## 👥 Authors

| Name | Role |
|------|------|
| **Adem Deroues** | Lead Developer — Architecture, Audio Engine, Firebase Integration, UI/UX |
| **Abderrahmane Elkedim** | Co-Developer — Islamic Features, Prayer Times, Adkar System, Qibla Compass |

---

## 📖 Overview

**MobPlay** is a full-featured, beautifully crafted Islamic mobile application that blends a modern audio streaming experience with essential spiritual tools for Muslims. The app offers Quran and nasheed playback, daily Adkar, prayer time reminders, a Qibla compass, and more — all wrapped in a sleek dark-gold design aesthetic.

---

## ✨ Features

### 🎵 Audio Streaming
- Stream Quranic recitations and Islamic audio from Firebase Storage
- Full-featured audio player with play/pause, seek, skip, shuffle, and repeat
- **Background playback** with lock-screen media controls (Android notification)
- Persistent mini-player across all screens
- Lyrics / subtitle display synced to audio

### 🕌 Islamic Spiritual Tools
- **Prayer Times** — real-time daily prayer schedule based on geolocation
- **Adkar** — categorized morning, evening, and situational Dhikr cards
- **Tasbih Counter** — digital counter for Dhikr repetitions
- **Qibla Compass** — live compass pointing toward Mecca using device sensors

### 🔐 Authentication & Security
- Email/Password sign-up & login via Firebase Auth
- **Biometric authentication** (fingerprint / face ID) on app launch
- Forgot password recovery flow
- Persistent session management

### ❤️ Personal Library
- Save favourite tracks to a personal Favorites collection (Firestore)
- Playlist creation and management
- Listening statistics dashboard (tracks played, total time, streaks)

### 👤 User Profile
- Edit profile (name, avatar via image picker)
- Audio quality settings
- Download preferences
- Notification settings
- App language switcher (multilingual support via `AppTranslations`)

### 🎨 Design & UX
- Deep dark theme with a **gold accent** color system
- Glassmorphism effects with `BackdropFilter` blur
- Animated splash screen with Lottie animations
- Animated bubble background on key screens
- Smooth page transitions with custom route animations
- Shimmer loading placeholders
- Haptic feedback on navigation
- Custom animated bottom navigation bar with sliding capsule indicator

---

## 🏗️ Architecture

```
mobplay/
├── lib/
│   ├── core/
│   │   ├── l10n/          # Localization (LocaleProvider, AppTranslations)
│   │   ├── theme/         # AppColors, AppTextStyles, AppTheme
│   │   ├── utils/         # Route transitions
│   │   └── widgets/       # Reusable widgets (GlassCard, MiniPlayer, ShimmerLoading, etc.)
│   │
│   ├── models/            # Data models (SongModel, PlaylistModel, AdkarModel, AppUser)
│   │
│   ├── providers/         # State management via Provider
│   │   ├── auth_provider.dart
│   │   ├── player_provider.dart
│   │   ├── song_provider.dart
│   │   ├── favorites_provider.dart
│   │   └── stats_provider.dart
│   │
│   ├── services/          # Business logic & external integrations
│   │   ├── audio_player_service.dart    # just_audio wrapper
│   │   ├── auth_service.dart            # Firebase Auth
│   │   ├── biometric_service.dart       # local_auth
│   │   ├── favorites_service.dart       # Firestore favorites
│   │   ├── lyrics_service.dart          # Subtitle/lyrics sync
│   │   ├── playlist_service.dart        # Playlist CRUD
│   │   ├── prayer_times_service.dart    # Prayer API + geolocation
│   │   └── song_service.dart            # Firestore song fetching
│   │
│   ├── screens/
│   │   ├── auth/          # Login, Signup, ForgotPassword
│   │   ├── home/          # Dashboard, HomeScreen
│   │   ├── player/        # FullPlayerScreen, LyricsScreen
│   │   ├── adkar/         # AdkarScreen, AdkarDetailScreen
│   │   ├── prayer/        # PrayerTimesScreen, TasbihCard
│   │   ├── qibla/         # QiblaCompassScreen
│   │   ├── favorites/     # FavoritesScreen
│   │   ├── profile/       # ProfileScreen, EditProfile, Settings screens
│   │   └── splash/        # SplashScreen
│   │
│   ├── firebase_options.dart
│   └── main.dart          # App entry point, routing, biometric gate
│
├── assets/
│   ├── images/            # Background images, icons
│   ├── icons/             # Custom icon assets
│   └── audio/             # Local audio samples
│
├── android/               # Android platform code
├── ios/                   # iOS platform code
├── firebase.json          # Firebase hosting & Firestore config
├── firestore.rules        # Firestore security rules
├── firestore.indexes.json # Firestore composite indexes
└── pubspec.yaml
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | Provider |
| **Backend / Database** | Firebase Firestore |
| **Authentication** | Firebase Auth |
| **File Storage** | Firebase Storage |
| **Audio Engine** | just_audio + just_audio_background |
| **Audio Session** | audio_session |
| **Reactive Streams** | RxDart |
| **Biometrics** | local_auth |
| **Location** | geolocator |
| **Compass** | flutter_compass |
| **Charts** | fl_chart |
| **Image Picking** | image_picker |
| **Caching** | cached_network_image |
| **Animations** | Lottie, shimmer |
| **Localization** | Custom AppTranslations system |
| **HTTP** | http |
| **Storage** | shared_preferences, path_provider |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK (bundled with Flutter)
- Android Studio or Xcode (for device targets)
- A Firebase project with **Auth**, **Firestore**, and **Storage** enabled

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/adem-dr/mobplay.git
cd mobplay

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# Place your google-services.json (Android) and GoogleService-Info.plist (iOS)
# or run: flutterfire configure

# 4. Run the app
flutter run
```

### Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** authentication
3. Create a **Firestore** database with the appropriate collections (`songs`, `users`, `favorites`, `playlists`)
4. Enable **Firebase Storage** for audio files
5. Deploy Firestore rules: `firebase deploy --only firestore:rules`

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Splash** | Animated intro screen with Lottie |
| **Login / Signup** | Firebase Auth with biometric gate |
| **Dashboard** | Home feed with featured content and stats |
| **Full Player** | Immersive audio player with lyrics support |
| **Prayer Times** | Daily prayer schedule with Tasbih counter |
| **Adkar** | Categorized morning/evening Dhikr cards |
| **Qibla Compass** | Live compass toward Mecca |
| **Favorites** | Personal saved track collection |
| **Profile** | User settings, audio quality, language, notifications |

---

## 🌍 Localization

The app supports multiple languages via the custom `AppTranslations` system. Language can be switched at runtime from the Profile screen. To add a new language, extend the `AppTranslations` class with a new locale map.

---

## 🔒 Security

- Firestore access is gated by security rules (`firestore.rules`)
- Biometric authentication required on every app launch
- Firebase Auth tokens managed automatically
- Sensitive keys are kept out of version control via `.gitignore`

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

<p align="center">
  Made with ❤️ by <b>Adem Deroues</b> & <b>Abderrahmane Elkedim</b>
</p>
