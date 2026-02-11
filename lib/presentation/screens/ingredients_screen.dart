import 'dart:io';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/usecases/get_ingredients_usecase.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Ingredients screen
class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({super.key});

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Ingredient> _ingredients = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadIngredients();
    }
  }

  Future<void> _loadIngredients() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final newIngredients = await ServiceLocator.instance
          .get<GetIngredientsUseCase>()
          .call(offset: _offset, limit: _limit);

      if (mounted) {
        setState(() {
          _ingredients.addAll(newIngredients);
          _offset += newIngredients.length;
          _hasMore = newIngredients.length == _limit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('error')), backgroundColor: Colors.red),
        );
      }
    }
  }

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
          title: Text(loc.translate('ingredients')),
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
        body: _ingredients.isEmpty && !_isLoading
            ? Center(child: Text(loc.translate('ingredients')))
            : ListView.builder(
                controller: _scrollController,
                itemCount: _ingredients.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _ingredients.length) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final ingredient = _ingredients[index];
                  return ListTile(
                    leading: ingredient.photoPath != null
                        ? CircleAvatar(backgroundImage: FileImage(File(ingredient.photoPath!)))
                        : const CircleAvatar(child: Icon(Icons.fastfood)),
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.calories} kcal'),
                    onTap: () async {
                      await Navigator.of(context).pushNamed('/add_ingredient', arguments: ingredient);
                      // Refresh list after editing
                      setState(() {
                        _ingredients.clear();
                        _offset = 0;
                        _hasMore = true;
                      });
                      _loadIngredients();
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).pushNamed('/add_ingredient');
            // Refresh list after adding
            setState(() {
              _ingredients.clear();
              _offset = 0;
              _hasMore = true;
            });
            _loadIngredients();
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
