import 'package:cooking_master/domain/entities/user.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Register a new user
  Future<User> register({required String email, required String password, required String name});

  /// Login an existing user
  Future<User> login({required String email, required String password});

  /// Logout the current user
  Future<void> logout();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get current user
  Future<User?> getCurrentUser();
}
