import 'package:cooking_master/domain/repositories/recipe_repository.dart';

class DeleteRecipeUseCase {
  final RecipeRepository repository;

  DeleteRecipeUseCase(this.repository);

  Future<void> call({required String userId, required String recipeId}) async {
    await repository.deleteRecipe(userId, recipeId);
  }
}