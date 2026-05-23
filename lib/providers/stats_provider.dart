import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsProvider extends ChangeNotifier {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _totalListens = 0;
  int _totalListeningMinutes = 0;
  List<double> _dailyMinutes = List.filled(31, 0);

  int get totalListens => _totalListens;
  int get totalListeningMinutes => _totalListeningMinutes;
  List<double> get dailyMinutes => _dailyMinutes;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statsSubscription;

  String get _userIdPrefix => _auth.currentUser?.uid ?? 'guest';

  StatsProvider() {
    // Listen to authentication changes to load stats exclusively for each user
    _authSubscription = _auth.authStateChanges().listen((user) {
      _loadAndSyncStats(user);
    });
  }

  Future<void> _loadAndSyncStats(User? user) async {
    _statsSubscription?.cancel();
    
    final prefix = user?.uid ?? 'guest';
    final prefs = await SharedPreferences.getInstance();

    // 1. First, load whatever is stored in local SharedPreferences for this specific user/guest
    final month = DateTime.now().month;
    final savedMonth = prefs.getInt('${prefix}_stats_month') ?? month;

    if (savedMonth != month) {
      await prefs.setInt('${prefix}_stats_month', month);
      await prefs.setInt('${prefix}_stats_listens', 0);
      await prefs.setInt('${prefix}_stats_minutes', 0);
      _totalListens = 0;
      _totalListeningMinutes = 0;
      _dailyMinutes = List.filled(31, 0);
      for (int i = 0; i < 31; i++) {
        await prefs.remove('${prefix}_stats_day_$i');
      }
    } else {
      _totalListens = prefs.getInt('${prefix}_stats_listens') ?? 0;
      _totalListeningMinutes = prefs.getInt('${prefix}_stats_minutes') ?? 0;
      _dailyMinutes = List.filled(31, 0);
      for (int i = 0; i < 31; i++) {
        _dailyMinutes[i] = prefs.getDouble('${prefix}_stats_day_$i') ?? 0;
      }
    }
    notifyListeners();

    // 2. If the user is signed in, set up a stream to sync stats in real-time from Firestore
    if (user != null) {
      final docRef = _fs.collection('users').doc(user.uid).collection('stats').doc('overview');
      
      // Check if document exists, if not, write current local stats to Firestore (initial upload)
      final doc = await docRef.get();
      if (!doc.exists) {
        await _uploadStatsToFirestore(user.uid);
      }

      // Listen to remote changes to stay synced
      _statsSubscription = docRef.snapshots().listen((snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          _totalListens = data['totalListens'] ?? 0;
          _totalListeningMinutes = data['totalListeningMinutes'] ?? 0;
          
          final List<dynamic>? dailyList = data['dailyMinutes'];
          if (dailyList != null) {
            _dailyMinutes = List.filled(31, 0);
            for (int i = 0; i < dailyList.length && i < 31; i++) {
              _dailyMinutes[i] = (dailyList[i] as num).toDouble();
            }
          }

          // Persist these loaded remote stats to local SharedPreferences for this specific user prefix
          await _saveStatsLocally(user.uid);
          notifyListeners();
        }
      });
    }
  }

  Future<void> _saveStatsLocally(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${prefix}_stats_listens', _totalListens);
    await prefs.setInt('${prefix}_stats_minutes', _totalListeningMinutes);
    for (int i = 0; i < 31; i++) {
      await prefs.setDouble('${prefix}_stats_day_$i', _dailyMinutes[i]);
    }
  }

  Future<void> _uploadStatsToFirestore(String uid) async {
    final docRef = _fs.collection('users').doc(uid).collection('stats').doc('overview');
    await docRef.set({
      'totalListens': _totalListens,
      'totalListeningMinutes': _totalListeningMinutes,
      'dailyMinutes': _dailyMinutes,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Called each time a surah starts playing
  Future<void> recordListen() async {
    _totalListens++;
    final prefix = _userIdPrefix;
    
    // Update local cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${prefix}_stats_listens', _totalListens);
    notifyListeners();

    // Upload to Firestore if logged in
    final user = _auth.currentUser;
    if (user != null) {
      await _uploadStatsToFirestore(user.uid);
    }
  }

  /// Called to add listening time (in minutes)
  Future<void> addListeningTime(int minutes) async {
    _totalListeningMinutes += minutes;
    final day = DateTime.now().day - 1; // 0-indexed
    if (day >= 0 && day < 31) {
      _dailyMinutes[day] += minutes;
    }

    final prefix = _userIdPrefix;
    
    // Update local cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${prefix}_stats_minutes', _totalListeningMinutes);
    if (day >= 0 && day < 31) {
      await prefs.setDouble('${prefix}_stats_day_$day', _dailyMinutes[day]);
    }
    notifyListeners();

    // Upload to Firestore if logged in
    final user = _auth.currentUser;
    if (user != null) {
      await _uploadStatsToFirestore(user.uid);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _statsSubscription?.cancel();
    super.dispose();
  }
}
