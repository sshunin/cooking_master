import 'dart:convert';
import 'package:cooking_master/core/exceptions/exceptions.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getRecipes(String userId);
  Future<void> saveRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String userId, String recipeId);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final Storage storage;

  RecipeLocalDataSourceImpl(this.storage);

  @override
  Future<List<RecipeModel>> getRecipes(String userId) async {
    try {
      final result = await storage.query(
        'recipes',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result.map((row) {
        final map = Map<String, dynamic>.from(row);
        final ingredientsJson = map['ingredients'] as String?;
        map['ingredients'] = ingredientsJson != null ? json.decode(ingredientsJson) : [];
        final stepsJson = map['steps'] as String?;
        map['steps'] = stepsJson != null ? json.decode(stepsJson) : [];
        return RecipeModel.fromJson(map);
      }).toList();
    } catch (e) {
      throw StorageException('Failed to load recipes: $e');
    }
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    try {
      final map = recipe.toJson();
      map['ingredients'] = json.encode(map['ingredients']);
      map['steps'] = json.encode(map['steps']);
      await storage.insert('recipes', map);
    } catch (e) {
      throw StorageException('Failed to save recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String userId, String recipeId) async {
    try {
      await storage.delete(
        'recipes',
        where: 'id = ? AND user_id = ?',
        whereArgs: [recipeId, userId],
      );
    } catch (e) {
      throw StorageException('Failed to delete recipe: $e');
    }
  }
}
