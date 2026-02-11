import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Home screen after authentication
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(loc.translate('cooking_master')),
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
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: _buildWelcomeCard(context, authProvider, loc),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _navigateToScreen(context, index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_menu),
              label: loc.translate('receipts'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_basket),
              label: loc.translate('ingredients'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb),
              label: loc.translate('recommendations'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider, AppLocalizations loc) {
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    // Use theme colors if available, falling back to the specific design colors
    final cardColor = theme.colorScheme.primaryContainer; 
    final textColor = theme.appBarTheme.backgroundColor ?? const Color(0xFF001F3F);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loc.translate('welcome', {'name': user?.name ?? 'User'}),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('email_label', {'email': user?.email ?? 'N/A'}),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('recipes_soon'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToScreen(BuildContext context, int index) async {
    switch (index) {
      case 0:
        await Navigator.of(context).pushNamed('/receipts');
        break;
      case 1:
        await Navigator.of(context).pushNamed('/ingredients');
        break;
      case 2:
        await Navigator.of(context).pushNamed('/recommendations');
        break;
    }

    // Reset selection to Home when returning from other screens
    if (mounted && index != 0) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
