import 'package:cooking_master/data/datasources/ingredient_local_datasource.dart';
import 'package:cooking_master/data/models/ingredient_model.dart';
import 'package:cooking_master/domain/entities/ingredient.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientLocalDataSource dataSource;

  IngredientRepositoryImpl(this.dataSource);

  @override
  Future<void> saveIngredient(Ingredient ingredient) async {
    await dataSource.saveIngredient(IngredientModel.fromEntity(ingredient));
  }

  @override
  Future<List<Ingredient>> getIngredients({int offset = 0, int limit = 20}) async {
    return await dataSource.getIngredients(offset: offset, limit: limit);
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    await dataSource.updateIngredient(IngredientModel.fromEntity(ingredient));
  }
}