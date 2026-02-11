import 'package:cooking_master/domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  IngredientModel({super.id, required super.name, required super.calories, super.photoPath});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'photo_path': photoPath,
    };
  }

  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(id: ingredient.id, name: ingredient.name, calories: ingredient.calories, photoPath: ingredient.photoPath);
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      calories: json['calories'] as int,
      photoPath: json['photo_path'] as String?,
    );
  }
}