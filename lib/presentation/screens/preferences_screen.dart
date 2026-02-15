import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';
import 'package:cooking_master/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('preferences')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/CM_ingredients_list_background.png',
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _LanguageSelectionSection(),
              const SizedBox(height: 16),
              _PasswordManagementSection(),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageSelectionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('language'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioListTile<Locale>(
              title: Text(loc.translate('english')),
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (value) => localeProvider.setLocale(const Locale('en')),
            ),
            RadioListTile<Locale>(
              title: Text(loc.translate('russian')),
              value: const Locale('ru'),
              groupValue: currentLocale,
              onChanged: (value) => localeProvider.setLocale(const Locale('ru')),
            ),
            RadioListTile<Locale>(
              title: Text(loc.translate('german')),
              value: const Locale('de'),
              groupValue: currentLocale,
              onChanged: (value) => localeProvider.setLocale(const Locale('de')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordManagementSection extends StatefulWidget {
  @override
  State<_PasswordManagementSection> createState() => _PasswordManagementSectionState();
}

class _PasswordManagementSectionState extends State<_PasswordManagementSection> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ServiceLocator.instance.get<AuthRepository>();
      await authRepo.updatePassword(_passwordController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('password_updated'))),
        );
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('password_management'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: loc.translate('new_password'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  tooltip: loc.translate(_obscureText ? 'show_password' : 'hide_password'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(loc.translate('update_password')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}