import 'package:cooking_master/domain/entities/meal_plan.dart';
import 'package:cooking_master/domain/repositories/meal_plan_repository.dart';

class GetMealPlanUseCase {
  final MealPlanRepository repository;
  GetMealPlanUseCase(this.repository);
  Future<MealPlan?> call({required DateTime date, required String userId}) =>
      repository.getMealPlanForDate(date, userId);
}

class GetMealPlansForRangeUseCase {
  final MealPlanRepository repository;
  GetMealPlansForRangeUseCase(this.repository);
  Future<List<MealPlan>> call({required DateTime start, required DateTime end, required String userId}) =>
      repository.getMealPlansForRange(start, end, userId);
}

class AddRecipeToMealPlanUseCase {
  final MealPlanRepository repository;
  AddRecipeToMealPlanUseCase(this.repository);
  Future<void> call({required DateTime date, required String recipeId}) =>
      repository.addRecipeToPlan(date, recipeId);
}

class RemoveRecipeFromMealPlanUseCase {
  final MealPlanRepository repository;
  RemoveRecipeFromMealPlanUseCase(this.repository);
  Future<void> call({required DateTime date, required String recipeId}) =>
      repository.removeRecipeFromPlan(date, recipeId);
}