import 'package:cooking_master/domain/entities/shopping_list_item.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingListItem>> getShoppingList();
  Future<void> addItem(ShoppingListItem item);
  Future<void> updateItem(ShoppingListItem item);
  Future<void> deleteItem(int id);
  Future<void> clearList();
}