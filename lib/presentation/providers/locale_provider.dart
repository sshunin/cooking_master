import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  LocaleProvider() {
    _loadLocale();
  }

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final code = _prefs?.getString('localeCode') ?? 'en';
      _locale = Locale(code);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString('localeCode', locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }
}
