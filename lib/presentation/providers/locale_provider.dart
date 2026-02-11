import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {

  LocaleProvider() {
    _loadLocale();
  }
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void _loadLocale() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString('localeCode') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('localeCode', locale.languageCode);
  }
}
