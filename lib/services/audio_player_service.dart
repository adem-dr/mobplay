import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobplay/models/song_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  SongModel? _currentSong;
  List<SongModel> _queue = [];
  int _currentIndex = 0;
  bool _isShuffled = false;
  SongModel? get currentSong => _currentSong;
  List<SongModel> get queue => _queue;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PositionData> get positionDataStream => Rx.combineLatest2<Duration, Duration?, PositionData>(positionStream, durationStream, (position, duration) => PositionData(position, duration ?? Duration.zero));

  Future<Uri?> _getArtUri(String coverUrl) async {
    if (coverUrl.isEmpty) return null;
    if (coverUrl.startsWith('asset://')) {
      try {
        final path = coverUrl.replaceFirst('asset://', '');
        final byteData = await rootBundle.load(path);
        final tempDir = await getTemporaryDirectory();
        final fileName = path.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ));
        return Uri.file(file.path);
      } catch (e) {
        debugPrint('Error loading asset cover in AudioPlayerService: $e');
        return null;
      }
    }
    try {
      return Uri.parse(coverUrl);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setSongSource(SongModel song) async {
    final artUri = await _getArtUri(song.coverUrl);
    final mediaItem = MediaItem(
      id: song.id,
      album: song.album.isNotEmpty ? song.album : 'Quran',
      title: song.title,
      artist: song.artist,
      artUri: artUri,
    );
    await _player.setAudioSource(AudioSource.uri(
      Uri.parse(song.audioUrl),
      tag: mediaItem,
    ));
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    if (queue != null) { _queue = queue; _currentIndex = queue.indexWhere((s) => s.id == song.id); if (_currentIndex == -1) { _queue = [song]; _currentIndex = 0; } } else { _queue = [song]; _currentIndex = 0; }
    _currentSong = song;
    await _setSongSource(song);
    await _player.play();
  }

  Future<void> togglePlayPause() async { if (_player.playing) await _player.pause(); else await _player.play(); }

  Future<void> playNext() async {
    if (_currentIndex < _queue.length - 1) { _currentIndex++; _currentSong = _queue[_currentIndex]; await _setSongSource(_currentSong!); await _player.play(); }
  }

  Future<void> playPrevious() async {
    if (_player.position.inSeconds > 3) await _player.seek(Duration.zero);
    else if (_currentIndex > 0) { _currentIndex--; _currentSong = _queue[_currentIndex]; await _setSongSource(_currentSong!); await _player.play(); }
  }

  Future<void> seekTo(Duration position) async => await _player.seek(position);
  Future<void> setVolume(double volume) async => await _player.setVolume(volume);
  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);
  void toggleShuffle() { _isShuffled = !_isShuffled; if (_isShuffled) _queue.shuffle(); }
  bool _isRepeat = false;
  bool get isRepeat => _isRepeat;

  Future<void> replay() async => await _player.seek(Duration.zero);

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    _player.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
  }

  Future<void> dispose() async => await _player.dispose();
}

class PositionData {
  final Duration position;
  final Duration duration;
  const PositionData(this.position, this.duration);
}
