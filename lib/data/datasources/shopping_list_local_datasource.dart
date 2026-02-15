import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/shopping_list_item_model.dart';

abstract class ShoppingListLocalDataSource {
  Future<List<ShoppingListItemModel>> getShoppingList();
  Future<void> addItem(ShoppingListItemModel item);
  Future<void> updateItem(ShoppingListItemModel item);
  Future<void> deleteItem(int id);
  Future<void> clearList();
}

class ShoppingListLocalDataSourceImpl implements ShoppingListLocalDataSource {
  final Storage storage;

  ShoppingListLocalDataSourceImpl(this.storage);

  @override
  Future<List<ShoppingListItemModel>> getShoppingList() async {
    final result = await storage.query('shopping_list', orderBy: 'is_bought ASC, id DESC');
    return result.map((e) => ShoppingListItemModel.fromJson(e)).toList();
  }

  @override
  Future<void> addItem(ShoppingListItemModel item) async {
    await storage.insert('shopping_list', item.toJson());
  }

  @override
  Future<void> updateItem(ShoppingListItemModel item) async {
    await storage.update('shopping_list', item.toJson(), where: 'id = ?', whereArgs: [item.id]);
  }

  @override
  Future<void> deleteItem(int id) async {
    await storage.delete('shopping_list', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearList() async {
    await storage.delete('shopping_list');
  }
}