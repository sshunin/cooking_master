import 'package:cooking_master/data/datasources/meal_plan_local_datasource.dart';
import 'package:cooking_master/data/models/meal_plan_model.dart';
import 'package:cooking_master/domain/entities/meal_plan.dart';
import 'package:cooking_master/domain/entities/recipe.dart';
import 'package:cooking_master/domain/repositories/meal_plan_repository.dart';
import 'package:cooking_master/domain/repositories/recipe_repository.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final MealPlanLocalDataSource localDataSource;
  final RecipeRepository recipeRepository;

  MealPlanRepositoryImpl(this.localDataSource, this.recipeRepository);

  String _dateToString(DateTime date) => date.toIso8601String().split('T').first;

  @override
  Future<List<MealPlan>> getMealPlansForRange(DateTime start, DateTime end, String userId) async {
    final startDateString = _dateToString(start);
    final endDateString = _dateToString(end);
    final mealPlanModels = await localDataSource.getMealPlansForRange(startDateString, endDateString);

    if (mealPlanModels.isEmpty) return [];

    final allUserRecipes = await recipeRepository.getRecipes(userId);
    final recipeMap = {for (var r in allUserRecipes) r.id: r};

    return mealPlanModels.map((model) {
      final recipes = model.recipeIds
          .map((id) => recipeMap[id])
          .whereType<Recipe>()
          .toList();
      return MealPlan(date: DateTime.parse(model.date), recipes: recipes);
    }).toList();
  }

  @override
  Future<MealPlan?> getMealPlanForDate(DateTime date, String userId) async {
    final dateString = _dateToString(date);
    final mealPlanModel = await localDataSource.getMealPlanForDate(dateString);

    if (mealPlanModel == null) return MealPlan(date: date, recipes: []);

    // Fetch all user recipes once to build a map for efficient lookup
    final allUserRecipes = await recipeRepository.getRecipes(userId);
    final recipeMap = {for (var r in allUserRecipes) r.id: r};

    final recipes = mealPlanModel.recipeIds
        .map((id) => recipeMap[id])
        .whereType<Recipe>()
        .toList();

    return MealPlan(date: date, recipes: recipes);
  }

  @override
  Future<void> addRecipeToPlan(DateTime date, String recipeId) async {
    final dateString = _dateToString(date);
    final existingPlan = await localDataSource.getMealPlanForDate(dateString);

    if (existingPlan != null) {
      if (!existingPlan.recipeIds.contains(recipeId)) {
        final updatedIds = List<String>.from(existingPlan.recipeIds)..add(recipeId);
        await localDataSource
            .saveMealPlan(MealPlanModel(date: dateString, recipeIds: updatedIds));
      }
    } else {
      await localDataSource
          .saveMealPlan(MealPlanModel(date: dateString, recipeIds: [recipeId]));
    }
  }

  @override
  Future<void> removeRecipeFromPlan(DateTime date, String recipeId) async {
    final dateString = _dateToString(date);
    final existingPlan = await localDataSource.getMealPlanForDate(dateString);

    if (existingPlan != null && existingPlan.recipeIds.contains(recipeId)) {
      final updatedIds = List<String>.from(existingPlan.recipeIds)..remove(recipeId);
      await localDataSource
          .saveMealPlan(MealPlanModel(date: dateString, recipeIds: updatedIds));
    }
  }
}