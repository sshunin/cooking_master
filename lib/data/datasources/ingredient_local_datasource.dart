import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/ingredient_model.dart';

abstract class IngredientLocalDataSource {
  Future<void> saveIngredient(IngredientModel ingredient);
  Future<List<IngredientModel>> getIngredients({int offset, int limit});
  Future<void> updateIngredient(IngredientModel ingredient);
}

class IngredientLocalDataSourceImpl implements IngredientLocalDataSource {
  final Storage storage;

  IngredientLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveIngredient(IngredientModel ingredient) async {
    await storage.insert('ingredients', ingredient.toJson());
  }

  @override
  Future<List<IngredientModel>> getIngredients({int offset = 0, int limit = 20}) async {
    final result = await storage.query('ingredients', limit: limit, offset: offset, orderBy: 'id DESC');
    return result.map((e) => IngredientModel.fromJson(e)).toList();
  }

  @override
  Future<void> updateIngredient(IngredientModel ingredient) async {
    await storage.update(
      'ingredients',
      ingredient.toJson(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }
}