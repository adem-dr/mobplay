class SongModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String audioUrl;
  final String coverUrl;
  final List<String>? genres;
  final int? playCount;
  final int? releaseYear;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    required this.audioUrl,
    required this.coverUrl,
    this.genres,
    this.playCount,
    this.releaseYear,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      album: json['album'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      playCount: json['playCount'],
      releaseYear: json['releaseYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'genres': genres,
      'playCount': playCount,
      'releaseYear': releaseYear,
    };
  }
}
