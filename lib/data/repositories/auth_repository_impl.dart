import 'package:cooking_master/core/exceptions/exceptions.dart';
import 'package:cooking_master/data/datasources/auth_local_datasource.dart';
import 'package:cooking_master/data/models/user_model.dart';
import 'package:cooking_master/domain/entities/user.dart';
import 'package:cooking_master/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl(this.localDataSource);
  final AuthLocalDataSource localDataSource;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if user already exists by email
      if (await localDataSource.userExistsByEmail(email)) {
        throw AuthenticationException('User with this email already exists');
      }

      // Store password and name locally for this mock implementation
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password_$email', password);
      await prefs.setString('name_$email', name);

      // TODO: Implement actual registration with API
      // For now, create a local user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      throw AuthenticationException('Registration failed: $e');
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      // Check if user exists in database
      if (!await localDataSource.userExistsByEmail(email)) {
        throw AuthenticationException('User not found or credentials are wrong');
      }

      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('password_$email');

      if (storedPassword != password) {
        throw AuthenticationException('Invalid password');
      }

      // TODO: Implement actual login with API
      // For now, create a local user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: prefs.getString('name_$email') ?? email.split('@')[0],
        createdAt: DateTime.now(),
      );

      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      throw AuthenticationException('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.removeUser();
    } catch (e) {
      throw AuthenticationException('Logout failed: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async => localDataSource.isUserSaved();

  @override
  Future<User?> getCurrentUser() async => localDataSource.getUser();

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw AuthenticationException('User not authenticated');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password_${user.email}', newPassword);
    } catch (e) {
      throw AuthenticationException('Failed to update password: $e');
    }
  }
}
