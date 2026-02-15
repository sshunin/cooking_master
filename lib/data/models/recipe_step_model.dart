import 'package:cooking_master/domain/entities/recipe_step.dart';

class RecipeStepModel extends RecipeStep {
  const RecipeStepModel({
    required super.name,
    required super.description,
    super.photoPath,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    return RecipeStepModel(
      name: json['name'] as String,
      description: json['description'] as String,
      photoPath: json['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'photo_path': photoPath,
    };
  }

  factory RecipeStepModel.fromEntity(RecipeStep step) {
    return RecipeStepModel(
      name: step.name,
      description: step.description,
      photoPath: step.photoPath,
    );
  }
}