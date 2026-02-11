import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';

class UpdateIngredientUseCase {
  final IngredientRepository repository;

  UpdateIngredientUseCase(this.repository);

  Future<void> call(Ingredient ingredient) async {
    return repository.updateIngredient(ingredient);
  }
}