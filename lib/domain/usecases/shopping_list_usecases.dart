import 'package:cooking_master/domain/entities/shopping_list_item.dart';
import 'package:cooking_master/domain/repositories/shopping_list_repository.dart';

class GetShoppingListUseCase {
  final ShoppingListRepository repository;
  GetShoppingListUseCase(this.repository);
  Future<List<ShoppingListItem>> call() => repository.getShoppingList();
}

class AddShoppingListItemUseCase {
  final ShoppingListRepository repository;
  AddShoppingListItemUseCase(this.repository);
  Future<void> call(ShoppingListItem item) => repository.addItem(item);
}

class UpdateShoppingListItemUseCase {
  final ShoppingListRepository repository;
  UpdateShoppingListItemUseCase(this.repository);
  Future<void> call(ShoppingListItem item) => repository.updateItem(item);
}

class DeleteShoppingListItemUseCase {
  final ShoppingListRepository repository;
  DeleteShoppingListItemUseCase(this.repository);
  Future<void> call(int id) => repository.deleteItem(id);
}

class ClearShoppingListUseCase {
  final ShoppingListRepository repository;
  ClearShoppingListUseCase(this.repository);
  Future<void> call() => repository.clearList();
}