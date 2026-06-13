import 'package:cooking_master/domain/entities/recipe.dart';

class MealPlan {
  final DateTime date;
  final List<Recipe> recipes;

  const MealPlan({
    required this.date,
    required this.recipes,
  });
}