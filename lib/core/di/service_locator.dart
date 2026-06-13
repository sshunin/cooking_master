import 'package:cooking_master/core/storage/sqlite_storage.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/core/ai/ai_client.dart';
import 'package:cooking_master/core/ai/openai_client.dart';
import 'package:cooking_master/core/ai/github_copilot_client.dart';
import 'package:cooking_master/data/datasources/auth_local_datasource.dart';
import 'package:cooking_master/data/datasources/ingredient_local_datasource.dart';
import 'package:cooking_master/data/datasources/recipe_local_datasource.dart';
import 'package:cooking_master/data/datasources/meal_plan_local_datasource.dart';
import 'package:cooking_master/data/datasources/shopping_list_local_datasource.dart';
import 'package:cooking_master/data/repositories/auth_repository_impl.dart';
import 'package:cooking_master/data/repositories/ingredient_repository_impl.dart';
import 'package:cooking_master/data/repositories/recipe_repository_impl.dart';
import 'package:cooking_master/data/repositories/meal_plan_repository_impl.dart';
import 'package:cooking_master/data/repositories/shopping_list_repository_impl.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';
import 'package:cooking_master/domain/repositories/recipe_repository.dart';
import 'package:cooking_master/domain/repositories/meal_plan_repository.dart';
import 'package:cooking_master/domain/repositories/shopping_list_repository.dart';
import 'package:cooking_master/domain/usecases/auth_usecases.dart';
import 'package:cooking_master/domain/usecases/get_ingredients_usecase.dart';
import 'package:cooking_master/domain/usecases/get_recipes_usecase.dart';
import 'package:cooking_master/domain/usecases/save_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/update_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_recipe_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/meal_plan_usecases.dart';
import 'package:cooking_master/domain/usecases/shopping_list_usecases.dart';

/// Service Locator for dependency injection
class ServiceLocator {

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();
  static final ServiceLocator _instance = ServiceLocator._internal();
  late Storage _storage;
  final Map<Type, dynamic> _singletons = {};

  /// Initialize the service locator with specific storage type
  static Future<void> initialize({String storageType = 'sqlite'}) async {
    await instance._initializeDependencies(storageType: storageType);
  }

  /// Get singleton instance
  static ServiceLocator get instance => _instance;

  Future<void> _initializeDependencies({required String storageType}) async {
    // Initialize storage based on type
    if (storageType == 'cloud') {
      _storage = CloudStorageImpl();
    } else if (storageType == 'persistent') {
      // SharedPreferences based persistent storage
      _storage = await SharedPreferencesStorageImpl.getInstance();
    } else if (storageType == 'sqlite') {
      _storage = await SqliteStorageImpl.getInstance();
    } else {
      _storage = LocalStorageImpl();
    }

    // Register storage
    _register<Storage>(_storage);

    // Register AI client backend according to saved preference
    final backend = (await _storage.getString('ai_backend')) ?? 'openai';
    if (backend == 'copilot') {
      _register<AIClient>(GitHubCopilotClient(_storage));
    } else {
      _register<AIClient>(OpenAIClient.create(_storage));
    }

    // Register data sources
    _register<AuthLocalDataSource>(
      AuthLocalDataSourceImpl(_storage),
    );

    _register<IngredientLocalDataSource>(
      IngredientLocalDataSourceImpl(_storage),
    );

    _register<RecipeLocalDataSource>(
      RecipeLocalDataSourceImpl(_storage),
    );

    _register<ShoppingListLocalDataSource>(
      ShoppingListLocalDataSourceImpl(_storage),
    );

    _register<MealPlanLocalDataSource>(
      MealPlanLocalDataSourceImpl(_storage),
    );

    // Register repositories
    _register<AuthRepository>(
      AuthRepositoryImpl(_get<AuthLocalDataSource>()),
    );

    _register<IngredientRepository>(
      IngredientRepositoryImpl(_get<IngredientLocalDataSource>()),
    );

    _register<RecipeRepository>(
      RecipeRepositoryImpl(_get<RecipeLocalDataSource>()),
    );

    _register<ShoppingListRepository>(
      ShoppingListRepositoryImpl(_get<ShoppingListLocalDataSource>()),
    );

    _register<MealPlanRepository>(
      MealPlanRepositoryImpl(
          _get<MealPlanLocalDataSource>(), _get<RecipeRepository>()),
    );

    // Register use cases
    _register<LoginUseCase>(
      LoginUseCase(_get<AuthRepository>()),
    );

    _register<RegisterUseCase>(
      RegisterUseCase(_get<AuthRepository>()),
    );

    _register<LogoutUseCase>(
      LogoutUseCase(_get<AuthRepository>()),
    );

    _register<CheckAuthUseCase>(
      CheckAuthUseCase(_get<AuthRepository>()),
    );

    _register<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(_get<AuthRepository>()),
    );

    _register<SaveIngredientUseCase>(
      SaveIngredientUseCase(_get<IngredientRepository>()),
    );

    _register<GetIngredientsUseCase>(
      GetIngredientsUseCase(_get<IngredientRepository>()),
    );

    _register<UpdateIngredientUseCase>(
      UpdateIngredientUseCase(_get<IngredientRepository>()),
    );
    _register<DeleteIngredientUseCase>(
      DeleteIngredientUseCase(_get<IngredientRepository>()),
    );

    _register<GetRecipesUseCase>(
      GetRecipesUseCase(_get<RecipeRepository>()),
    );

    _register<DeleteRecipeUseCase>(
      DeleteRecipeUseCase(_get<RecipeRepository>()),
    );

    _register<GetShoppingListUseCase>(
      GetShoppingListUseCase(_get<ShoppingListRepository>()),
    );

    _register<AddShoppingListItemUseCase>(
      AddShoppingListItemUseCase(_get<ShoppingListRepository>()),
    );

    _register<UpdateShoppingListItemUseCase>(
      UpdateShoppingListItemUseCase(_get<ShoppingListRepository>()),
    );

    _register<DeleteShoppingListItemUseCase>(
      DeleteShoppingListItemUseCase(_get<ShoppingListRepository>()),
    );

    _register<ClearShoppingListUseCase>(
      ClearShoppingListUseCase(_get<ShoppingListRepository>()),
    );

    _register<GetMealPlanUseCase>(
      GetMealPlanUseCase(_get<MealPlanRepository>()),
    );

    _register<GetMealPlansForRangeUseCase>(
      GetMealPlansForRangeUseCase(_get<MealPlanRepository>()),
    );

    _register<AddRecipeToMealPlanUseCase>(
      AddRecipeToMealPlanUseCase(_get<MealPlanRepository>()),
    );

    _register<RemoveRecipeFromMealPlanUseCase>(
      RemoveRecipeFromMealPlanUseCase(_get<MealPlanRepository>()),
    );
  }

  /// Register a singleton instance
  void _register<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Publicly replace or register a singleton instance for a type.
  /// Useful for runtime reconfiguration (e.g., switching AI backend).
  void registerInstance<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Get a singleton instance
  T _get<T>() {
    final instance = _singletons[T];
    if (instance == null) {
      throw Exception('No instance found for type $T');
    }
    return instance as T;
  }

  /// Public getter for getting dependencies
  T get<T>() => _get<T>();
}
