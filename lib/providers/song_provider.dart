import 'package:flutter/foundation.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:mobplay/services/song_service.dart';

class SongProvider extends ChangeNotifier {
  final SongService _songService = SongService();
  List<SongModel> _trendingSongs = [];
  List<SongModel> _recommendedSongs = [];
  List<SongModel> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  List<SongModel> get trendingSongs => _trendingSongs;
  List<SongModel> get recommendedSongs => _recommendedSongs;
  List<SongModel> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadTrending() async { _isLoading = true; notifyListeners(); try { _trendingSongs = await _songService.getTrendingSongs(); } catch (e) { debugPrint('Error loading trending: $e'); } _isLoading = false; notifyListeners(); }
  Future<void> loadRecommended() async { try { _recommendedSongs = await _songService.getRecommendedSongs(); } catch (e) { debugPrint('Error loading recommended: $e'); } notifyListeners(); }
  Future<void> searchSongs(String query) async { _searchQuery = query; if (query.isEmpty) { _searchResults = []; notifyListeners(); return; } try { _searchResults = await _songService.searchSongs(query); } catch (e) { debugPrint('Error searching: $e'); } notifyListeners(); }
  Future<void> loadGenre(String genre) async { _isLoading = true; notifyListeners(); try { _searchResults = await _songService.getSongsByGenre(genre); } catch (e) { debugPrint('Error loading genre: $e'); } _isLoading = false; notifyListeners(); }
}
