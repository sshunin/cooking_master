import 'package:cooking_master/data/datasources/shopping_list_local_datasource.dart';
import 'package:cooking_master/data/models/shopping_list_item_model.dart';
import 'package:cooking_master/domain/entities/shopping_list_item.dart';
import 'package:cooking_master/domain/repositories/shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListLocalDataSource localDataSource;

  ShoppingListRepositoryImpl(this.localDataSource);

  @override
  Future<List<ShoppingListItem>> getShoppingList() async {
    return await localDataSource.getShoppingList();
  }

  @override
  Future<void> addItem(ShoppingListItem item) async {
    await localDataSource.addItem(ShoppingListItemModel.fromEntity(item));
  }

  @override
  Future<void> updateItem(ShoppingListItem item) async {
    await localDataSource.updateItem(ShoppingListItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteItem(int id) async {
    await localDataSource.deleteItem(id);
  }

  @override
  Future<void> clearList() async {
    await localDataSource.clearList();
  }
}