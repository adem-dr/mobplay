import 'package:flutter/foundation.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:mobplay/services/audio_player_service.dart';
import 'package:mobplay/providers/stats_provider.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  StatsProvider? _statsProvider;

  SongModel? get currentSong => _audioService.currentSong;
  List<SongModel> get queue => _audioService.queue;
  bool get isPlaying => _audioService.isPlaying;
  Duration get position => _audioService.position;
  Duration get duration => _audioService.duration;
  bool get hasNext => _audioService.hasNext;
  bool get hasPrevious => _audioService.hasPrevious;
  bool get isRepeat => _audioService.isRepeat;

  Duration? _lastPosition;
  double _accumulatedSeconds = 0.0;
  String? _lastSongId;

  PlayerProvider() {
    _audioService.playerStateStream.listen((_) => notifyListeners());
    _audioService.positionStream.listen((pos) {
      _trackListeningTime(pos);
      notifyListeners();
    });
  }

  void _trackListeningTime(Duration currentPos) {
    if (!isPlaying || currentSong == null) {
      _lastPosition = null;
      return;
    }
    
    // If the song changed, reset the accumulator tracking for the current song segment
    if (_lastSongId != currentSong!.id) {
      _lastSongId = currentSong!.id;
      _lastPosition = null;
      return;
    }

    if (_lastPosition != null) {
      final diff = currentPos - _lastPosition!;
      if (diff.inMilliseconds > 0 && diff.inSeconds < 5) {
        _accumulatedSeconds += diff.inMilliseconds / 1000.0;
        if (_accumulatedSeconds >= 60.0) {
          final minutes = (_accumulatedSeconds / 60.0).floor();
          _statsProvider?.addListeningTime(minutes);
          _accumulatedSeconds -= minutes * 60.0;
        }
      }
    }
    _lastPosition = currentPos;
  }

  /// Inject stats provider for tracking
  void setStatsProvider(StatsProvider stats) {
    _statsProvider = stats;
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    await _audioService.playSong(song, queue: queue);
    // Track listen
    _statsProvider?.recordListen();
    notifyListeners();
  }

  Future<void> togglePlayPause() async { await _audioService.togglePlayPause(); notifyListeners(); }
  Future<void> playNext() async {
    await _audioService.playNext();
    _statsProvider?.recordListen();
    notifyListeners();
  }
  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    _statsProvider?.recordListen();
    notifyListeners();
  }
  Future<void> seekTo(Duration position) async { await _audioService.seekTo(position); notifyListeners(); }
  Future<void> setVolume(double volume) async { await _audioService.setVolume(volume); }
  Future<void> replay() async { await _audioService.replay(); notifyListeners(); }
  void toggleRepeat() { _audioService.toggleRepeat(); notifyListeners(); }
  @override
  void dispose() { _audioService.dispose(); super.dispose(); }
}
