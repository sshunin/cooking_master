import 'dart:convert';
import 'package:cooking_master/core/exceptions/exceptions.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/user_model.dart';

/// Abstract interface for authentication data source
abstract class AuthLocalDataSource {
  /// Save user login credentials
  Future<void> saveUser(UserModel user);

  /// Get saved user
  Future<UserModel?> getUser();

  /// Remove user (logout)
  Future<void> removeUser();

  /// Check if user exists (is authenticated)
  Future<bool> isUserSaved();

  /// Check if user exists by email
  Future<bool> userExistsByEmail(String email);
}

/// Implementation of AuthLocalDataSource using Storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl(this.storage);
  static const String _userKey = 'current_user';
  static const String _usersRegistryKey = 'registered_users';
  final Storage storage;

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await storage.saveString(_userKey, userJson);
      
      // Add user to registered users list
      await _addToRegistry(user.email);
    } catch (e) {
      throw StorageException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await storage.getString(_userKey);
      if (userJson == null) return null;
      
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (e) {
      throw StorageException('Failed to retrieve user: $e');
    }
  }

  @override
  @override
  Future<void> removeUser() async {
    try {
      await storage.removeString(_userKey);
    } catch (e) {
      throw StorageException('Failed to remove user: $e');
    }
  }

  @override
  Future<bool> isUserSaved() async => storage.containsKey(_userKey);

  @override
  Future<bool> userExistsByEmail(String email) async {
    try {
      final registryJson = await storage.getString(_usersRegistryKey);
      if (registryJson == null) return false;
      
      final emails = jsonDecode(registryJson) as List<dynamic>;
      return emails.contains(email);
    } catch (e) {
      return false;
    }
  }

  Future<void> _addToRegistry(String email) async {
    try {
      final registryJson = await storage.getString(_usersRegistryKey);
      var emails = <String>[];
      
      if (registryJson != null) {
        final decoded = jsonDecode(registryJson) as List<dynamic>;
        emails = decoded.cast<String>().toList();
      }
      
      if (!emails.contains(email)) {
        emails.add(email);
        await storage.saveString(_usersRegistryKey, jsonEncode(emails));
      }
    } catch (e) {
      // Silently fail registry update
    }
  }
}
