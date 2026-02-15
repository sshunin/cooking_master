import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/entities/recipe_step.dart';

class Recipe {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String? photoPath;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.photoPath,
    required this.ingredients,
    required this.steps,
  });
}