import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/datasources/auth_local_datasource.dart';
import 'package:cooking_master/data/repositories/auth_repository_impl.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';
import 'package:cooking_master/domain/usecases/auth_usecases.dart';

/// Service Locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  late Storage _storage;
  final Map<Type, dynamic> _singletons = {};

  ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  /// Initialize the service locator with specific storage type
  static void initialize({String storageType = 'local'}) {
    instance._initializeDependencies(storageType: storageType);
  }

  /// Get singleton instance
  static ServiceLocator get instance => _instance;

  void _initializeDependencies({required String storageType}) {
    // Initialize storage based on type
    if (storageType == 'cloud') {
      _storage = CloudStorageImpl();
    } else {
      _storage = LocalStorageImpl();
    }

    // Register storage
    _register<Storage>(_storage);

    // Register data sources
    _register<AuthLocalDataSource>(
      AuthLocalDataSourceImpl(_storage),
    );

    // Register repositories
    _register<AuthRepository>(
      AuthRepositoryImpl(_get<AuthLocalDataSource>()),
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
