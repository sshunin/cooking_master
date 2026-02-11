import 'package:cooking_master/core/di/service_locator.dart';
import 'package:cooking_master/core/exceptions/exceptions.dart';
import 'package:cooking_master/domain/entities/user.dart';
import 'package:cooking_master/domain/usecases/auth_usecases.dart';
import 'package:flutter/material.dart';

/// AuthProvider manages authentication state
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Check if user is authenticated on app startup
  Future<void> checkAuthentication() async {
    try {
      _setLoading(true);
      _clearError();
      
      final checkAuthUseCase = ServiceLocator.instance.get<CheckAuthUseCase>();
      _isAuthenticated = await checkAuthUseCase();

      if (_isAuthenticated) {
        // Fetch current user from storage and set it
        try {
          final getUserUseCase = ServiceLocator.instance.get<GetCurrentUserUseCase>();
          final user = await getUserUseCase();
          _currentUser = user;
        } catch (e) {
          // If fetching the user fails, clear authentication flag
          _isAuthenticated = false;
          _setError('Failed to load current user: $e');
        }
      }
    } on AuthenticationException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final registerUseCase =
          ServiceLocator.instance.get<RegisterUseCase>();
      _currentUser = await registerUseCase(
        email: email,
        password: password,
        name: name,
      );
      _isAuthenticated = true;
    } on AuthenticationException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<void> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      final loginUseCase = ServiceLocator.instance.get<LoginUseCase>();
      _currentUser = await loginUseCase(email: email, password: password);
      _isAuthenticated = true;
    } on AuthenticationException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearError();

      final logoutUseCase = ServiceLocator.instance.get<LogoutUseCase>();
      await logoutUseCase();
      _currentUser = null;
      _isAuthenticated = false;
    } on AuthenticationException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
