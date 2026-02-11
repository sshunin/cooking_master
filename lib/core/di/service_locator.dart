import 'package:cooking_master/core/storage/sqlite_storage.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/datasources/auth_local_datasource.dart';
import 'package:cooking_master/data/datasources/ingredient_local_datasource.dart';
import 'package:cooking_master/data/repositories/auth_repository_impl.dart';
import 'package:cooking_master/data/repositories/ingredient_repository_impl.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';
import 'package:cooking_master/domain/repositories/ingredient_repository.dart';
import 'package:cooking_master/domain/usecases/auth_usecases.dart';
import 'package:cooking_master/domain/usecases/get_ingredients_usecase.dart';
import 'package:cooking_master/domain/usecases/save_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/update_ingredient_usecase.dart';
import 'package:cooking_master/domain/usecases/delete_ingredient_usecase.dart';

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

    // Register data sources
    _register<AuthLocalDataSource>(
      AuthLocalDataSourceImpl(_storage),
    );

    _register<IngredientLocalDataSource>(
      IngredientLocalDataSourceImpl(_storage),
    );

    // Register repositories
    _register<AuthRepository>(
      AuthRepositoryImpl(_get<AuthLocalDataSource>()),
    );

    _register<IngredientRepository>(
      IngredientRepositoryImpl(_get<IngredientLocalDataSource>()),
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
  }

  /// Register a singleton instance
  void _register<T>(T instance) {
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
