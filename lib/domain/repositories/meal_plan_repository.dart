import 'package:cooking_master/domain/entities/meal_plan.dart';

abstract class MealPlanRepository {
  Future<List<MealPlan>> getMealPlansForRange(DateTime start, DateTime end, String userId);
  Future<MealPlan?> getMealPlanForDate(DateTime date, String userId);
  Future<void> addRecipeToPlan(DateTime date, String recipeId);
  Future<void> removeRecipeFromPlan(DateTime date, String recipeId);
}