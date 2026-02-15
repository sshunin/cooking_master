import 'package:cooking_master/domain/entities/shopping_list_item.dart';

class ShoppingListItemModel extends ShoppingListItem {
  const ShoppingListItemModel({
    super.id,
    required super.name,
    super.isBought,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      isBought: (json['is_bought'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_bought': isBought ? 1 : 0,
    };
  }

  factory ShoppingListItemModel.fromEntity(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.id,
      name: item.name,
      isBought: item.isBought,
    );
  }
}