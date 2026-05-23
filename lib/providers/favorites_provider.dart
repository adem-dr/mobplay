import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:mobplay/services/favorites_service.dart';
import 'package:mobplay/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favService = FavoritesService();
  final BiometricService _biometricService = BiometricService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<SongModel> _favorites = [];
  List<SongModel> get favorites => _favorites;

  StreamSubscription<List<SongModel>>? _favsSubscription;
  StreamSubscription<User?>? _authSubscription;

  FavoritesProvider() {
    // Listen to authentication changes to load favorites exclusively for the logged-in user
    _authSubscription = _auth.authStateChanges().listen((user) {
      _setupFavoritesStream(user);
    });
  }

  void _setupFavoritesStream(User? user) {
    _favsSubscription?.cancel();
    if (user != null) {
      _favsSubscription = _favService.getFavorites().listen((favs) {
        _favorites = favs;
        notifyListeners();
      });
    } else {
      _favorites = [];
      notifyListeners();
    }
  }

  bool isFavorite(String songId) {
    return _favorites.any((song) => song.id == songId);
  }

  Future<void> addFavorite(SongModel song) async {
    await _favService.addFavorite(song);
  }

  Future<bool> removeFavorite(String songId) async {
    await _favService.removeFavorite(songId);
    return true;
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (isFavorite(song.id)) {
      await removeFavorite(song.id);
    } else {
      await addFavorite(song);
    }
  }

  @override
  void dispose() {
    _favsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
