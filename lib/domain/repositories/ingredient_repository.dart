import 'package:cooking_master/domain/entities/ingredient.dart';

abstract class IngredientRepository {
  Future<void> saveIngredient(Ingredient ingredient);
  Future<List<Ingredient>> getIngredients({int offset, int limit});
  Future<void> updateIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(int id);
}