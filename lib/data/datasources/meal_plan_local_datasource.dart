import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/meal_plan_model.dart';

abstract class MealPlanLocalDataSource {
  Future<List<MealPlanModel>> getMealPlansForRange(String startDate, String endDate);
  Future<MealPlanModel?> getMealPlanForDate(String date);
  Future<void> saveMealPlan(MealPlanModel mealPlan);
}

class MealPlanLocalDataSourceImpl implements MealPlanLocalDataSource {
  final Storage storage;
  MealPlanLocalDataSourceImpl(this.storage);

  @override
  Future<List<MealPlanModel>> getMealPlansForRange(String startDate, String endDate) async {
    final result = await storage.query(
      'meal_plans',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    if (result.isEmpty) return [];
    return result.map((e) => MealPlanModel.fromJson(e)).toList();
  }

  @override
  Future<MealPlanModel?> getMealPlanForDate(String date) async {
    final result =
        await storage.query('meal_plans', where: 'date = ?', whereArgs: [date]);
    if (result.isEmpty) return null;
    return MealPlanModel.fromJson(result.first);
  }

  @override
  Future<void> saveMealPlan(MealPlanModel mealPlan) async {
    await storage.insert('meal_plans', mealPlan.toJson());
  }
}