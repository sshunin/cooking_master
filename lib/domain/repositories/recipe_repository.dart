import 'package:cooking_master/domain/entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes(String userId);
  Future<void> saveRecipe(Recipe recipe);
  Future<void> deleteRecipe(String userId, String recipeId);
}