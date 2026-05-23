import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale (fr / ar / en) and persists choice.
class LocaleProvider extends ChangeNotifier {
  String _locale = 'fr';
  String get locale => _locale;

  /// Human-readable label for picker UI
  String get label {
    switch (_locale) {
      case 'ar': return 'العربية';
      case 'en': return 'English';
      default:   return 'Français';
    }
  }

  /// Whether current locale is RTL
  bool get isRtl => _locale == 'ar';

  LocaleProvider() { _init(); }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    _locale = p.getString('app_locale') ?? 'fr';
    notifyListeners();
  }

  Future<void> setLocale(String code) async {
    if (code == _locale) return;
    _locale = code;
    final p = await SharedPreferences.getInstance();
    await p.setString('app_locale', code);
    notifyListeners();
  }
}
