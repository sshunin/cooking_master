import 'package:cooking_master/data/models/ingredient_model.dart';
import 'package:cooking_master/data/models/recipe_step_model.dart';
import 'package:cooking_master/domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    super.photoPath,
    required super.ingredients,
    required super.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      photoPath: json['photo_path'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'ingredients': ingredients.map((e) => IngredientModel.fromEntity(e).toJson()).toList(),
      'steps': steps.map((e) => RecipeStepModel.fromEntity(e).toJson()).toList(),
    };
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      userId: recipe.userId,
      name: recipe.name,
      description: recipe.description,
      photoPath: recipe.photoPath,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
    );
  }
}