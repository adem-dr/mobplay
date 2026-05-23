import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobplay/models/playlist_model.dart';

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<PlaylistModel>> getUserPlaylists(String userId) async {
    final snapshot = await _firestore.collection('playlists').where('ownerId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => PlaylistModel.fromFirestore(doc)).toList();
  }
  Future<PlaylistModel?> getPlaylistById(String id) async {
    final doc = await _firestore.collection('playlists').doc(id).get();
    if (doc.exists) return PlaylistModel.fromFirestore(doc);
    return null;
  }
  Future<String> createPlaylist(PlaylistModel playlist) async {
    final docRef = await _firestore.collection('playlists').add(playlist.toJson());
    return docRef.id;
  }
  Future<void> updatePlaylist(String id, Map<String, dynamic> data) async {
    await _firestore.collection('playlists').doc(id).update({...data, 'updatedAt': Timestamp.now()});
  }
  Future<void> deletePlaylist(String id) async => await _firestore.collection('playlists').doc(id).delete();
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _firestore.collection('playlists').doc(playlistId).update({'songIds': FieldValue.arrayUnion([songId]), 'updatedAt': Timestamp.now()});
  }
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _firestore.collection('playlists').doc(playlistId).update({'songIds': FieldValue.arrayRemove([songId]), 'updatedAt': Timestamp.now()});
  }
}
