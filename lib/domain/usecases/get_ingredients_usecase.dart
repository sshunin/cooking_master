import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';

class GetIngredientsUseCase {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  Future<List<Ingredient>> call({int offset = 0, int limit = 20}) async {
    return repository.getIngredients(offset: offset, limit: limit);
  }
}