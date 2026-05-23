import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Prayer time model
class PrayerTime {
  final String name;
  final String nameAr;
  final String time;
  final IconType iconType;

  const PrayerTime({
    required this.name,
    required this.nameAr,
    required this.time,
    required this.iconType,
  });
}

enum IconType { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// Service that fetches prayer times from Aladhan API
class PrayerTimesService extends ChangeNotifier {
  List<PrayerTime> _prayers = [];
  String _hijriDate = '';
  String _hijriMonth = '';
  String _hijriYear = '';
  String _gregorianDate = '';
  String _city = 'Alger';
  String _country = 'Algérie';
  bool _isLoading = false;
  String? _error;
  int _nextPrayerIndex = 0;
  Duration _timeUntilNext = Duration.zero;

  List<PrayerTime> get prayers => _prayers;
  String get hijriDate => _hijriDate;
  String get hijriMonth => _hijriMonth;
  String get hijriYear => _hijriYear;
  String get gregorianDate => _gregorianDate;
  String get city => _city;
  String get country => _country;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get nextPrayerIndex => _nextPrayerIndex;
  Duration get timeUntilNext => _timeUntilNext;
  PrayerTime? get nextPrayer =>
      _prayers.isNotEmpty && _nextPrayerIndex < _prayers.length
          ? _prayers[_nextPrayerIndex]
          : null;

  PrayerTimesService() {
    fetchPrayerTimes();
  }

  /// Fetch prayer times for today
  Future<void> fetchPrayerTimes({String? city, String? country}) async {
    if (city != null) _city = city;
    if (country != null) _country = country;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      int method = 3; // Default to Muslim World League
      if (_country.toLowerCase().contains('france')) {
        method = 12;
      } else if (_country.toLowerCase().contains('alger') || _country.toLowerCase().contains('algér')) {
        method = 5; // Egyptian General Authority of Survey (Standard for Algeria)
      }

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity/${now.day}-${now.month}-${now.year}'
        '?city=$_city&country=$_country&method=$method',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final hijri = data['data']['date']['hijri'];
        final gregorian = data['data']['date']['gregorian'];

        _hijriDate = hijri['day'] ?? '';
        _hijriMonth = hijri['month']?['en'] ?? '';
        _hijriYear = hijri['year'] ?? '';
        _gregorianDate = '${gregorian['weekday']?['en'] ?? ''}, '
            '${gregorian['day']} ${gregorian['month']?['en'] ?? ''} ${gregorian['year']}';

        // Extract real timings dynamically from Aladhan API response
        _prayers = [
          PrayerTime(name: 'Fajr',    nameAr: 'الفجر',    time: _cleanTime(timings['Fajr']), iconType: IconType.fajr),
          PrayerTime(name: 'Sunrise',  nameAr: 'الشروق',   time: _cleanTime(timings['Sunrise']), iconType: IconType.sunrise),
          PrayerTime(name: 'Dhuhr',   nameAr: 'الظهر',    time: _cleanTime(timings['Dhuhr']), iconType: IconType.dhuhr),
          PrayerTime(name: 'Asr',     nameAr: 'العصر',    time: _cleanTime(timings['Asr']), iconType: IconType.asr),
          PrayerTime(name: 'Maghrib', nameAr: 'المغرب',   time: _cleanTime(timings['Maghrib']), iconType: IconType.maghrib),
          PrayerTime(name: 'Isha',    nameAr: 'العشاء',    time: _cleanTime(timings['Isha']), iconType: IconType.isha),
        ];

        _computeNextPrayer();
      } else {
        _error = 'Failed to fetch prayer times';
        _setFallbackTimes();
      }
    } catch (e) {
      debugPrint('Prayer times error: $e');
      _error = e.toString();
      _setFallbackTimes();
    }

    _isLoading = false;
    notifyListeners();
  }

  String _cleanTime(String? raw) {
    if (raw == null) return '--:--';
    // Remove timezone info like " (CET)"
    return raw.replaceAll(RegExp(r'\s*\(.*\)'), '').trim();
  }

  void _computeNextPrayer() {
    final now = DateTime.now();
    for (int i = 0; i < _prayers.length; i++) {
      final parts = _prayers[i].time.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final prayerTime = DateTime(now.year, now.month, now.day, h, m);
      if (prayerTime.isAfter(now)) {
        _nextPrayerIndex = i;
        _timeUntilNext = prayerTime.difference(now);
        return;
      }
    }
    // All prayers passed → next is Fajr tomorrow
    _nextPrayerIndex = 0;
    if (_prayers.isNotEmpty) {
      final parts = _prayers[0].time.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final tomorrow = DateTime(now.year, now.month, now.day + 1, h, m);
      _timeUntilNext = tomorrow.difference(now);
    }
  }

  void _setFallbackTimes() {
    _prayers = [
      const PrayerTime(name: 'Fajr',    nameAr: 'الفجر',    time: '04:12', iconType: IconType.fajr),
      const PrayerTime(name: 'Sunrise',  nameAr: 'الشروق',   time: '05:48', iconType: IconType.sunrise),
      const PrayerTime(name: 'Dhuhr',   nameAr: 'الظهر',    time: '12:48', iconType: IconType.dhuhr),
      const PrayerTime(name: 'Asr',     nameAr: 'العصر',    time: '16:32', iconType: IconType.asr),
      const PrayerTime(name: 'Maghrib', nameAr: 'المغرب',   time: '19:48', iconType: IconType.maghrib),
      const PrayerTime(name: 'Isha',    nameAr: 'العشاء',    time: '21:18', iconType: IconType.isha),
    ];
    _computeNextPrayer();
  }

  void updateLocation(String city, String country) {
    fetchPrayerTimes(city: city, country: country);
  }
}
