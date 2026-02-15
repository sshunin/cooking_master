import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/ai/ai_client.dart';
import 'package:cooking_master/core/ai/openai_client.dart';
import 'package:cooking_master/core/ai/github_copilot_client.dart';
import 'package:cooking_master/core/storage/storage.dart';

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
          const Divider(),
          ListTile(
            title: Text(loc.translate('ai_backend')),
            subtitle: Text(loc.translate('ai_backend_description')),
          ),
          FutureBuilder<String?>(
            future: ServiceLocator.instance.get<Storage>().getString('ai_backend'),
            builder: (ctx, snap) {
              final current = snap.data ?? 'openai';
              return Column(
                children: [
                  RadioListTile<String>(
                    value: 'openai',
                    groupValue: current,
                    title: Text(loc.translate('openai')),
                    onChanged: (v) async {
                      if (v == null) return;
                      await ServiceLocator.instance.get<Storage>().saveString('ai_backend', v);
                      ServiceLocator.instance.registerInstance<AIClient>(OpenAIClient.create(ServiceLocator.instance.get<Storage>()));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.translate('ai_backend')}: ${loc.translate('openai')}')));
                    },
                  ),
                  RadioListTile<String>(
                    value: 'copilot',
                    groupValue: current,
                    title: Text(loc.translate('copilot')),
                    onChanged: (v) async {
                      if (v == null) return;
                      await ServiceLocator.instance.get<Storage>().saveString('ai_backend', v);
                      ServiceLocator.instance.registerInstance<AIClient>(GitHubCopilotClient(ServiceLocator.instance.get<Storage>()));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.translate('ai_backend')}: ${loc.translate('copilot')}')));
                    },
                  ),
                ],
              );
            },
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
