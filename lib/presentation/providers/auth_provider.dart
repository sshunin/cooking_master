import 'package:cooking_master/domain/entities/user.dart';
import 'package:cooking_master/domain/usecases/auth_usecases.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  User? _user;
  User? get user => _user;
  User? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;
  String? get errorMessage => _error;

  Future<void> checkAuthentication() => checkAuth();

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final isAuthenticated = await _checkAuthUseCase();
      if (isAuthenticated) {
        _user = await _getCurrentUserUseCase();
      } else {
        _user = null;
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _loginUseCase(email: email, password: password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({required String email, required String password, required String name}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _registerUseCase(email: email, password: password, name: name);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _logoutUseCase();
      _user = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}