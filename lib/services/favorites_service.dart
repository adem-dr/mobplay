import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobplay/models/song_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addFavorite(SongModel song) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    await _fs.collection('users').doc(uid).collection('favorites').doc(song.id).set(song.toJson());
  }

  Future<void> removeFavorite(String songId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _fs.collection('users').doc(uid).collection('favorites').doc(songId).delete();
  }

  Future<bool> isFavorite(String songId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _fs.collection('users').doc(uid).collection('favorites').doc(songId).get();
    return doc.exists;
  }

  Stream<List<SongModel>> getFavorites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _fs.collection('users').doc(uid).collection('favorites')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => SongModel.fromJson(doc.data())).toList());
  }
}
