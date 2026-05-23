import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
class AuthProvider extends ChangeNotifier {
  final AuthService _s = AuthService();
  AppUser? _user;
  bool _loading = false;
  String? _err;
  AppUser? get user => _user;
  bool get loading => _loading;
  String? get err => _err;
  bool get loggedIn => _user != null;
  Future<bool> signUp({required String email, required String pw, required String fn, required String ln, required DateTime dob}) async {
    _loading = true; _err = null; notifyListeners();
    try { await _s.signUp(email, pw, fn, ln, dob); await _load(); return true; }
    catch (e) { _err = e.toString().replaceAll('Exception: ', ''); return false; }
    finally { _loading = false; notifyListeners(); }
  }
  Future<bool> login(String email, String pw) async {
    _loading = true; _err = null; notifyListeners();
    try { await _s.login(email, pw); await _load(); return true; }
    catch (e) { _err = e.toString(); if (_err!.contains('user-not-found')) _err = 'No account'; if (_err!.contains('wrong-password')) _err = 'Wrong password'; return false; }
    finally { _loading = false; notifyListeners(); }
  }
  Future<void> resetPw(String email) async {
    _loading = true; _err = null; notifyListeners();
    try { await _s.resetPw(email); } catch (e) { _err = e.toString(); }
    finally { _loading = false; notifyListeners(); }
  }
  Future<void> signOut() async { await _s.signOut(); _user = null; notifyListeners(); }
  Future<void> checkAuth() async { await _load(); }
  Future<bool> updateProfile({required String displayName, File? imageFile}) async {
    _loading = true;
    _err = null;
    notifyListeners();
    try {
      await _s.updateProfile(displayName: displayName, imageFile: imageFile);
      await _load();
      return true;
    } catch (e) {
      _err = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    _loading = true;
    _err = null;
    notifyListeners();
    try {
      await _s.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return true;
    } catch (e) {
      _err = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<void> _load() async { try { _user = await _s.getUser(); } catch (e) { _err = e.toString(); } notifyListeners(); }
}
