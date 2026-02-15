import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/entities/shopping_list_item.dart';
import 'package:cooking_master/domain/usecases/shopping_list_usecases.dart';
import 'package:flutter/material.dart';

class ShoppingListProvider extends ChangeNotifier {
  final GetShoppingListUseCase _getShoppingListUseCase;
  final AddShoppingListItemUseCase _addShoppingListItemUseCase;
  final UpdateShoppingListItemUseCase _updateShoppingListItemUseCase;
  final DeleteShoppingListItemUseCase _deleteShoppingListItemUseCase;
  final ClearShoppingListUseCase _clearShoppingListUseCase;

  ShoppingListProvider(
    this._getShoppingListUseCase,
    this._addShoppingListItemUseCase,
    this._updateShoppingListItemUseCase,
    this._deleteShoppingListItemUseCase,
    this._clearShoppingListUseCase,
  );

  List<ShoppingListItem> _items = [];
  List<ShoppingListItem> get items => _items;

  Future<void> loadItems() async {
    _items = await _getShoppingListUseCase();
    notifyListeners();
  }

  Future<void> addItem(String name) async {
    await _addShoppingListItemUseCase(ShoppingListItem(name: name));
    await loadItems();
  }

  Future<void> addIngredients(List<Ingredient> ingredients) async {
    for (final ingredient in ingredients) {
      // Check if item already exists to avoid duplicates (simple check by name)
      if (!_items.any((item) => item.name.toLowerCase() == ingredient.name.toLowerCase() && !item.isBought)) {
        await _addShoppingListItemUseCase(ShoppingListItem(name: ingredient.name));
      }
    }
    await loadItems();
  }

  Future<void> toggleItem(ShoppingListItem item) async {
    await _updateShoppingListItemUseCase(ShoppingListItem(
      id: item.id,
      name: item.name,
      isBought: !item.isBought,
    ));
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _deleteShoppingListItemUseCase(id);
    await loadItems();
  }

  Future<void> clearList() async {
    await _clearShoppingListUseCase();
    await loadItems();
  }
}