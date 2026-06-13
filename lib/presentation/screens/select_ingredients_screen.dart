import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/i18n/app_localizations.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/usecases/get_ingredients_usecase.dart';
import 'package:flutter/material.dart';

class SelectIngredientsScreen extends StatefulWidget {
  final List<Ingredient> initialSelectedIngredients;

  const SelectIngredientsScreen({
    super.key,
    this.initialSelectedIngredients = const [],
  });

  @override
  State<SelectIngredientsScreen> createState() => _SelectIngredientsScreenState();
}

class _SelectIngredientsScreenState extends State<SelectIngredientsScreen> {
  List<Ingredient> _availableIngredients = [];
  List<Ingredient> _selectedIngredients = [];
  bool _isLoading = true;
  final TextEditingController _availableSearchController = TextEditingController();
  final TextEditingController _selectedSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIngredients = List.from(widget.initialSelectedIngredients);
    _loadIngredients();
  }

  @override
  void dispose() {
    _availableSearchController.dispose();
    _selectedSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    try {
      final allIngredients = await ServiceLocator.instance.get<GetIngredientsUseCase>()();
      if (mounted) {
        setState(() {
          final selectedIds = _selectedIngredients.map((e) => e.id).toSet();
          _availableIngredients = allIngredients.where((i) => !selectedIds.contains(i.id)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_selectedIngredients),
        ),
        title: Text(loc.translate('select_ingredients') != 'select_ingredients' ? loc.translate('select_ingredients') : 'Select Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(_selectedIngredients),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/CM_ingredients_list_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildList(
                      title: 'Available',
                      items: _availableIngredients,
                      isAvailableList: true,
                      searchController: _availableSearchController,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _buildList(
                      title: 'Selected',
                      items: _selectedIngredients,
                      isAvailableList: false,
                      searchController: _selectedSearchController,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildList({
    required String title,
    required List<Ingredient> items,
    required bool isAvailableList,
    required TextEditingController searchController,
  }) {
    return DragTarget<Ingredient>(
      onWillAccept: (data) => true,
      onAccept: (ingredient) {
        setState(() {
          if (isAvailableList) {
            if (!_availableIngredients.any((i) => i.id == ingredient.id)) {
              _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
              _availableIngredients.add(ingredient);
            }
          } else {
            if (!_selectedIngredients.any((i) => i.id == ingredient.id)) {
              _availableIngredients.removeWhere((i) => i.id == ingredient.id);
              _selectedIngredients.add(ingredient);
            }
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('search_ingredients'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(8),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: Container(
                color: candidateData.isNotEmpty ? Colors.orange.withOpacity(0.1) : null,
                child: Builder(builder: (context) {
                  final filteredItems = items.where((i) => i.name.toLowerCase().contains(searchController.text.toLowerCase())).toList();
                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final ingredient = filteredItems[index];
                    return Draggable<Ingredient>(
                      data: ingredient,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.white,
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(ingredient.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _buildListItem(ingredient),
                      ),
                      child: _buildListItem(ingredient),
                    );
                  },
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListItem(Ingredient ingredient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        title: Text(ingredient.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text('${ingredient.calories} kcal', style: const TextStyle(fontSize: 12)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}