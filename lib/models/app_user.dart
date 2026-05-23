import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? photoUrl; // Can be a local file path or a network URL

  AppUser({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.photoUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth: data['dateOfBirth'] != null ? (data['dateOfBirth'] as Timestamp).toDate() : null,
      photoUrl: data['photoUrl'],
    );
  }

  /// Returns true if the photoUrl is a local file path (not a network URL)
  bool get isLocalPhoto =>
      photoUrl != null &&
      !photoUrl!.startsWith('http://') &&
      !photoUrl!.startsWith('https://');

  String get displayName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
