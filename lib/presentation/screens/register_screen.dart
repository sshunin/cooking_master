import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('register')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/preferences'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) => SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('name'),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.translate('email'),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: loc.translate('password'),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  obscureText: true,
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleRegister(context, authProvider),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(loc.translate('register_btn')),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(loc.translate('already_have_account')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    // Validate input
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorDialog(context, AppLocalizations.of(context).translate('please_fill_all'));
      return;
    }

    await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (authProvider.errorMessage != null) {
      _showErrorDialog(context, authProvider.errorMessage!);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('error')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).translate('ok')),
          ),
        ],
      ),
    );
  }
}
