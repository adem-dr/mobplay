import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String id;
  final String title;
  final String ownerId;
  final List<String> songIds;
  final String? coverUrl;
  final DateTime? updatedAt;

  const PlaylistModel({
    required this.id,
    required this.title,
    required this.ownerId,
    this.songIds = const [],
    this.coverUrl,
    this.updatedAt,
  });

  factory PlaylistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaylistModel(
      id: doc.id,
      title: data['title'] ?? '',
      ownerId: data['ownerId'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
      coverUrl: data['coverUrl'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'ownerId': ownerId,
    'songIds': songIds,
    if (coverUrl != null) 'coverUrl': coverUrl,
    'updatedAt': Timestamp.now(),
  };
}
