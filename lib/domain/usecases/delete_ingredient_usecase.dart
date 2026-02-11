import 'package:cooking_master/domain/repositories/ingredient_repository.dart';

class DeleteIngredientUseCase {
  final IngredientRepository repository;

  DeleteIngredientUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deleteIngredient(id);
  }
}
