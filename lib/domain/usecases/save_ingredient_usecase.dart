import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';

class SaveIngredientUseCase {
  final IngredientRepository repository;

  SaveIngredientUseCase(this.repository);

  Future<void> call(Ingredient ingredient) async {
    return repository.saveIngredient(ingredient);
  }
}