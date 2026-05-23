import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobplay/models/song_model.dart';

class SongService {
  final String _baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<SongModel>> getTrendingSongs({int limit = 114}) async {
    return _fetchSurahs();
  }

  Future<List<SongModel>> getRecommendedSongs({int limit = 10}) async {
    return _fetchSurahs();
  }

  Future<List<SongModel>> _fetchSurahs() async {
    try {
      final url = Uri.parse('$_baseUrl/surah');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['data'] ?? [];
        
          return results.map((item) {
            final int number = item['number'];
            final String numStr = number.toString().padLeft(3, '0');
            final String audioUrl = 'https://server8.mp3quran.net/afs/$numStr.mp3';

            return SongModel(
              id: number.toString(),
              title: item['englishName'] ?? 'Unknown',
              artist: item['name'] ?? 'Unknown',
              album: item['englishNameTranslation'] ?? '',
              audioUrl: audioUrl,
              // Local bundled asset — always works without network
              coverUrl: 'asset://assets/images/alafasy.png',
              genres: [item['revelationType'] ?? ''],
            );
          }).toList();
      }
    } catch (e) {
      print('Error fetching Quran: $e');
    }
    return [];
  }

  Future<List<SongModel>> searchSongs(String query, {int limit = 20}) async {
    final allSurahs = await _fetchSurahs();
    if (query.isEmpty) return allSurahs;
    
    return allSurahs.where((s) => 
      s.title.toLowerCase().contains(query.toLowerCase()) || 
      s.artist.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<SongModel>> getSongsByGenre(String genre, {int limit = 20}) async {
    return _fetchSurahs();
  }

  Future<SongModel?> getSongById(String id) async {
    final all = await _fetchSurahs();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> incrementPlayCount(String songId) async {}
}
