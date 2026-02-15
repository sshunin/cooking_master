import 'dart:io';
import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/usecases/get_ingredients_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_ingredient_usecase.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String _sortCriteria = '';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Ingredient> get _displayedIngredients {
    if (_searchQuery.isEmpty) return _ingredients;
    final q = _searchQuery.toLowerCase();
    return _ingredients.where((i) => i.name.toLowerCase().contains(q)).toList();
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

  void _applySort(String criteria) {
    setState(() {
      if (_sortCriteria == criteria) {
        _isAscending = !_isAscending;
      } else {
        _sortCriteria = criteria;
        _isAscending = true;
      }

      if (_sortCriteria == 'name') {
        _ingredients.sort((a, b) {
          final cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return _isAscending ? cmp : -cmp;
        });
      } else if (_sortCriteria == 'calories') {
        _ingredients.sort((a, b) {
          final cmp = a.calories.compareTo(b.calories);
          return _isAscending ? cmp : -cmp;
        });
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name'),
              trailing: _sortCriteria == 'name'
                  ? Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () {
                _applySort('name');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Calories'),
              trailing: _sortCriteria == 'calories'
                  ? Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () {
                _applySort('calories');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/CM_ingredients_list_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _ingredients.clear();
                              _offset = 0;
                              _hasMore = true;
                            });
                            _loadIngredients();
                          },
                        )
                      : null,
                  hintText: loc.translate('search_ingredients') ,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            Expanded(
              child: _ingredients.isEmpty && !_isLoading
                  ? Center(child: Text(loc.translate('ingredients')))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _displayedIngredients.length + ((_searchQuery.isEmpty && _hasMore) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_searchQuery.isEmpty && index == _displayedIngredients.length) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        if (index >= _displayedIngredients.length) return const SizedBox.shrink();
                        final ingredient = _displayedIngredients[index];
                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          child: ListTile(
                    leading: ingredient.photoPath != null
                        ? CircleAvatar(backgroundImage: FileImage(File(ingredient.photoPath!)))
                        : const CircleAvatar(child: Icon(Icons.fastfood)),
                    title: Text(ingredient.name),
                    subtitle: Text(loc.translate('calories_value', {'value': ingredient.calories.toString()})),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final loc = AppLocalizations.of(context);
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(loc.translate('delete')),
                            content: Text(loc.translate('confirm_delete')),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(loc.translate('cancel'))),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(loc.translate('delete'))),
                            ],
                          ),
                        );

                        if (confirmed != true) return;

                        // Ensure id exists
                        if (ingredient.id == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('error')), backgroundColor: Colors.red),
                            );
                          }
                          return;
                        }

                        try {
                          // Delete photo file if present
                          if (ingredient.photoPath != null) {
                            final f = File(ingredient.photoPath!);
                            if (await f.exists()) {
                              await f.delete();
                            }
                          }

                          // Delete from storage via use case
                          await ServiceLocator.instance.get<DeleteIngredientUseCase>().call(ingredient.id!);

                          // Remove from local list
                          if (mounted) {
                            setState(() {
                              _ingredients.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('deleted'))),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(loc.translate('error')), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    ),
                  ),
                );
                },
              ),
            ),
          ],
        ),
      ],
    ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'sort',
                onPressed: _showSortOptions,
                child: const Icon(Icons.sort),
              ),
              FloatingActionButton(
                heroTag: 'add',
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
            ],
          ),
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
