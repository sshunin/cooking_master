import 'dart:io';

import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/usecases/get_recipes_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_recipe_usecase.dart';
import 'package:cooking_master/presentation/providers/auth_provider.dart';
import 'package:cooking_master/presentation/providers/recipe_provider.dart';
import 'package:cooking_master/presentation/screens/recipe_view_screen.dart';
import 'package:cooking_master/presentation/screens/select_ingredients_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SortOption { nameAsc, nameDesc, newest, oldest }

/// Receipts screen
class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider(
        ServiceLocator.instance.get<GetRecipesUseCase>(),
        ServiceLocator.instance.get<DeleteRecipeUseCase>(),
      ),
      child: const _ReceiptsScreenContent(),
    );
  }
}

class _ReceiptsScreenContent extends StatefulWidget {
  const _ReceiptsScreenContent();

  @override
  State<_ReceiptsScreenContent> createState() => _ReceiptsScreenContentState();
}

class _ReceiptsScreenContentState extends State<_ReceiptsScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Ingredient> _filterIngredients = [];
  SortOption _currentSortOption = SortOption.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<RecipeProvider>().loadRecipes(user.id);
      }
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
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
          title: Text(loc.translate('receipts')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed('/add_recipe');
                if (result == true && context.mounted) {
                  final user = context.read<AuthProvider>().user;
                  if (user != null) {
                    context.read<RecipeProvider>().loadRecipes(user.id);
                  }
                }
              },
              tooltip: loc.translate('add_recipe') != 'add_recipe' ? loc.translate('add_recipe') : 'Add Recipe',
            ),
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/CM_ingredients_list_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.recipes.isEmpty) {
                  return Center(
                    child: Text(loc.translate('recipes_soon')),
                  );
                }

                final filteredRecipes = provider.recipes
                    .where((r) {
                  final matchesName = r.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesIngredients = _filterIngredients.isEmpty ||
                      _filterIngredients.every((filterItem) =>
                          r.ingredients.any((recipeItem) => recipeItem.id == filterItem.id));
                  return matchesName && matchesIngredients;
                }).toList();

                filteredRecipes.sort((a, b) {
                  switch (_currentSortOption) {
                    case SortOption.nameAsc:
                      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                    case SortOption.nameDesc:
                      return b.name.toLowerCase().compareTo(a.name.toLowerCase());
                    case SortOption.newest:
                      return b.id.compareTo(a.id);
                    case SortOption.oldest:
                      return a.id.compareTo(b.id);
                  }
                });

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: loc.translate('search_recipes'),
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<SortOption>(
                            icon: const Icon(Icons.sort),
                            tooltip: loc.translate('sort_by'),
                            onSelected: (SortOption result) {
                              setState(() {
                                _currentSortOption = result;
                              });
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
                              PopupMenuItem<SortOption>(
                                value: SortOption.newest,
                                child: Text(loc.translate('sort_newest')),
                              ),
                              PopupMenuItem<SortOption>(
                                value: SortOption.oldest,
                                child: Text(loc.translate('sort_oldest')),
                              ),
                              PopupMenuItem<SortOption>(
                                value: SortOption.nameAsc,
                                child: Text(loc.translate('sort_name_asc')),
                              ),
                              PopupMenuItem<SortOption>(
                                value: SortOption.nameDesc,
                                child: Text(loc.translate('sort_name_desc')),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.filter_list,
                                color: _filterIngredients.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey),
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SelectIngredientsScreen(
                                    initialSelectedIngredients: _filterIngredients,
                                  ),
                                ),
                              );
                              if (result != null && result is List<Ingredient>) {
                                setState(() => _filterIngredients = result);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_filterIngredients.isNotEmpty)
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filterIngredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = _filterIngredients[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(ingredient.name),
                                onDeleted: () {
                                  setState(() {
                                    _filterIngredients.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return _RecipeCard(recipe: recipe);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Use the first step's photo as the recipe thumbnail if available
    final String? photoPath = recipe.photoPath ?? (recipe.steps.isNotEmpty ? recipe.steps.first.photoPath : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecipeViewScreen(recipe: recipe),
            ),
          );
          if (context.mounted) {
            final user = context.read<AuthProvider>().user;
            if (user != null) {
              context.read<RecipeProvider>().loadRecipes(user.id);
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photoPath != null)
              SizedBox(
                height: 200,
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 200,
                child: Image.asset(
                  'assets/images/CM_Default_Receipe.png',
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${recipe.ingredients.length} ingredients • ${recipe.steps.length} steps',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, recipe),
                    tooltip: AppLocalizations.of(context).translate('delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Recipe recipe) {
    final loc = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final recipeProvider = context.read<RecipeProvider>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(loc.translate('delete')),
          content: Text(loc.translate('confirm_recipe_delete')),
          actions: <Widget>[
            TextButton(
              child: Text(loc.translate('cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(loc.translate('delete'), style: const TextStyle(color: Colors.red)),
              onPressed: () {
                final userId = authProvider.user?.id;
                if (userId != null) {
                  recipeProvider.deleteRecipe(userId, recipe.id);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
