import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  /// Sign up with email/password. Handles reCAPTCHA CONFIGURATION_NOT_FOUND
  /// gracefully by retrying once — the SDK falls back silently on retry.
  Future<UserCredential> signUp(
      String email, String pw, String fn, String ln, DateTime dob) async {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) age--;
    if (age < 13) throw Exception('Must be at least 13');

    UserCredential uc;
    try {
      uc = await _auth.createUserWithEmailAndPassword(
          email: email, password: pw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'internal-error' ||
          e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        uc = await _auth.createUserWithEmailAndPassword(
            email: email, password: pw);
      } else {
        rethrow;
      }
    }

    await _fs.collection('users').doc(uc.user!.uid).set({
      'uid': uc.user!.uid,
      'email': email,
      'firstName': fn,
      'lastName': ln,
      'dateOfBirth': Timestamp.fromDate(dob),
      'createdAt': Timestamp.now(),
    });
    return uc;
  }

  /// Login with email/password, same reCAPTCHA resilience.
  Future<UserCredential> login(String email, String pw) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: pw);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'internal-error' ||
          e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        return await _auth.signInWithEmailAndPassword(
            email: email, password: pw);
      }
      rethrow;
    }
  }

  Future<void> resetPw(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final d = await _fs.collection('users').doc(u.uid).get();
    if (!d.exists) return null;
    final appUser = AppUser.fromFirestore(d);

    // Load local avatar path saved on this device
    final localPath = await getLocalAvatarPath(u.uid);
    if (localPath != null && appUser.photoUrl == null) {
      return AppUser(
        uid: appUser.uid,
        email: appUser.email,
        firstName: appUser.firstName,
        lastName: appUser.lastName,
        dateOfBirth: appUser.dateOfBirth,
        photoUrl: localPath, // use local path as photoUrl
      );
    }
    return appUser;
  }

  /// Saves an image file locally on the device and returns its path.
  Future<String> saveImageLocally(File imageFile, String uid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    final savedImage = await imageFile.copy('${avatarDir.path}/$uid.jpg');
    // Persist the path in shared_preferences so it survives app restarts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_$uid', savedImage.path);
    return savedImage.path;
  }

  /// Retrieves the locally saved avatar path for a given user.
  Future<String?> getLocalAvatarPath(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatar_$uid');
    if (path == null) return null;
    // Verify the file still exists on disk
    if (await File(path).exists()) return path;
    return null;
  }

  Future<void> updateProfile({required String displayName, File? imageFile}) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user logged in');

    // Save image locally on device (no Firebase Storage needed)
    if (imageFile != null) {
      await saveImageLocally(imageFile, u.uid);
    }

    final nameParts = displayName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await _fs.collection('users').doc(u.uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('No user logged in');
    if (u.email == null) throw Exception('User has no email');

    try {
      final credential = EmailAuthProvider.credential(
        email: u.email!,
        password: currentPassword,
      );
      await u.reauthenticateWithCredential(credential);
      await u.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('wrong_current_password');
      } else if (e.code == 'weak-password') {
        throw Exception('password_too_short');
      } else {
        throw Exception(e.message ?? e.code);
      }
    }
  }

  Stream<User?> stream() => _auth.authStateChanges();
}
