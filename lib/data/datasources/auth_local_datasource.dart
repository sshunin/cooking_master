import 'dart:convert';
import 'package:cooking_master/core/exceptions/exceptions.dart';
import 'package:cooking_master/core/storage/storage.dart';
import 'package:cooking_master/data/models/user_model.dart';

/// Abstract interface for authentication data source
abstract class AuthLocalDataSource {
  /// Save user login credentials
  Future<void> saveUser(UserModel user);

  /// Get saved user
  UserModel? getUser();

  /// Remove user (logout)
  Future<void> removeUser();

  /// Check if user exists (is authenticated)
  bool isUserSaved();
}

/// Implementation of AuthLocalDataSource using Storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'current_user';
  final Storage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await storage.saveString(_userKey, userJson);
    } catch (e) {
      throw StorageException('Failed to save user: $e');
    }
  }

  @override
  UserModel? getUser() {
    try {
      final userJson = storage.getString(_userKey);
      if (userJson == null) return null;
      
      final decoded = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(decoded);
    } catch (e) {
      throw StorageException('Failed to retrieve user: $e');
    }
  }

  @override
  Future<void> removeUser() async {
    try {
      await storage.removeString(_userKey);
    } catch (e) {
      throw StorageException('Failed to remove user: $e');
    }
  }

  @override
  bool isUserSaved() {
    return storage.containsKey(_userKey);
  }
}
