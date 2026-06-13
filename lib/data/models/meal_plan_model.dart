import 'dart:convert';

/// This model is for storage purposes only. It doesn't extend the entity.
class MealPlanModel {
  final String date; // YYYY-MM-DD
  final List<String> recipeIds;

  const MealPlanModel({
    required this.date,
    required this.recipeIds,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      date: json['date'] as String,
      recipeIds: List<String>.from(jsonDecode(json['recipe_ids'] as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'recipe_ids': jsonEncode(recipeIds),
    };
  }
}