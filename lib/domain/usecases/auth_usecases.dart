import 'package:cooking_master/domain/entities/user.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {

  LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<User> call({required String email, required String password}) => repository.login(email: email, password: password);
}

/// Use case for user registration
class RegisterUseCase {

  RegisterUseCase(this.repository);
  final AuthRepository repository;

  Future<User> call({
    required String email,
    required String password,
    required String name,
  }) => repository.register(email: email, password: password, name: name);
}

/// Use case for user logout
class LogoutUseCase {

  LogoutUseCase(this.repository);
  final AuthRepository repository;

  Future<void> call() => repository.logout();
}

/// Use case to check authentication status
class CheckAuthUseCase {

  CheckAuthUseCase(this.repository);
  final AuthRepository repository;

  Future<bool> call() => repository.isAuthenticated();
}

/// Use case to get current user
class GetCurrentUserUseCase {

  GetCurrentUserUseCase(this.repository);
  final AuthRepository repository;

  Future<User?> call() => repository.getCurrentUser();
}
