import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Recommendations screen
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(loc.translate('recommendations')),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/preferences'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
              tooltip: loc.translate('logout'),
            ),
          ],
        ),
        body: Center(
          child: Text(loc.translate('recommendations')),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
