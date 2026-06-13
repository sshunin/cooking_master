import 'package:cooking_master/domain/entities/meal_plan.dart';
import 'package:cooking_master/domain/usecases/meal_plan_usecases.dart';
import 'package:flutter/material.dart';

class MealPlannerProvider extends ChangeNotifier {
  final GetMealPlansForRangeUseCase _getMealPlansForRangeUseCase;
  final GetMealPlanUseCase _getMealPlanUseCase;
  final AddRecipeToMealPlanUseCase _addRecipeToMealPlanUseCase;
  final RemoveRecipeFromMealPlanUseCase _removeRecipeFromMealPlanUseCase;

  MealPlannerProvider(
    this._getMealPlanUseCase,
    this._getMealPlansForRangeUseCase,
    this._addRecipeToMealPlanUseCase,
    this._removeRecipeFromMealPlanUseCase,
  );

  Map<DateTime, MealPlan> _mealPlans = {};
  Map<DateTime, MealPlan> get mealPlans => _mealPlans;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPlansForMonth(String userId, DateTime month) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final plans = await _getMealPlansForRangeUseCase(start: firstDay, end: lastDay, userId: userId);
      for (final plan in plans) {
        _mealPlans[DateUtils.dateOnly(plan.date)] = plan;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlanForDate(String userId, DateTime date) async {
    final dateOnly = DateUtils.dateOnly(date);
    if (_mealPlans.containsKey(dateOnly)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final plan = await _getMealPlanUseCase(date: dateOnly, userId: userId);
      if (plan != null) {
        _mealPlans[dateOnly] = plan;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipeToPlan(
      String userId, DateTime date, String recipeId) async {
    await _addRecipeToMealPlanUseCase(date: date, recipeId: recipeId);
    _mealPlans.remove(DateUtils.dateOnly(date)); // Invalidate cache
    await loadPlanForDate(userId, date);
  }

  Future<void> removeRecipeFromPlan(
      String userId, DateTime date, String recipeId) async {
    await _removeRecipeFromMealPlanUseCase(date: date, recipeId: recipeId);
    _mealPlans.remove(DateUtils.dateOnly(date)); // Invalidate cache
    await loadPlanForDate(userId, date);
  }
}