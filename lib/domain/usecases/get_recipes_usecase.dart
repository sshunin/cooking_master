import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/repositories/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  Future<List<Recipe>> call(String userId) async {
    return await repository.getRecipes(userId);
  }
}