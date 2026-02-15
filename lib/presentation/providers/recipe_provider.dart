import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/usecases/get_recipes_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_recipe_usecase.dart';
import 'package:flutter/material.dart';

class RecipeProvider extends ChangeNotifier {
  final GetRecipesUseCase _getRecipesUseCase;
  final DeleteRecipeUseCase _deleteRecipeUseCase;

  RecipeProvider(this._getRecipesUseCase, this._deleteRecipeUseCase);

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRecipes(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recipes = await _getRecipesUseCase(userId);
    } catch (e) {
      debugPrint('Error loading recipes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String userId, String recipeId) async {
    try {
      await _deleteRecipeUseCase(userId: userId, recipeId: recipeId);
      _recipes.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting recipe: $e');
      // Optionally, show an error to the user
    }
  }
}