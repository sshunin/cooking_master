import 'package:cooking_master/data/datasources/recipe_local_datasource.dart';
import 'package:cooking_master/data/models/recipe_model.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource localDataSource;

  RecipeRepositoryImpl(this.localDataSource);

  @override
  Future<List<Recipe>> getRecipes(String userId) async {
    return await localDataSource.getRecipes(userId);
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    await localDataSource.saveRecipe(RecipeModel.fromEntity(recipe));
  }

  @override
  Future<void> deleteRecipe(String userId, String recipeId) async {
    await localDataSource.deleteRecipe(userId, recipeId);
  }
}