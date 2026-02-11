import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('preferences')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(loc.translate('language')),
            subtitle: Text(_localeName(loc, provider.locale.languageCode)),
          ),
          RadioListTile<String>(
            value: 'en',
            groupValue: provider.locale.languageCode,
            title: Text(loc.translate('english')),
            onChanged: (v) => provider.setLocale(const Locale('en')),
          ),
          RadioListTile<String>(
            value: 'ru',
            groupValue: provider.locale.languageCode,
            title: Text(loc.translate('russian')),
            onChanged: (v) => provider.setLocale(const Locale('ru')),
          ),
          RadioListTile<String>(
            value: 'de',
            groupValue: provider.locale.languageCode,
            title: Text(loc.translate('german')),
            onChanged: (v) => provider.setLocale(const Locale('de')),
          ),
        ],
      ),
    );
  }

  String _localeName(AppLocalizations loc, String code) {
    switch (code) {
      case 'ru':
        return loc.translate('russian');
      case 'de':
        return loc.translate('german');
      default:
        return loc.translate('english');
    }
  }
}
