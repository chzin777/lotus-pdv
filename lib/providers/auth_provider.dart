import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await UserService.getUserByUsername(username);
      
      if (user != null && user.password == password && user.isActive) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Usuário ou senha inválidos';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao realizar login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> registerUser(User user) async {
    try {
      final existingUser = await UserService.getUserByUsername(user.username);
      if (existingUser != null) {
        _errorMessage = 'Usuário já existe';
        return false;
      }
      
      final success = await UserService.addUser(user);
      if (success) {
        _errorMessage = '';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao registrar usuário: $e';
      return false;
    }
  }

  Future<void> loadUsers() async {
    try {
      await UserService.getUsers();
    } catch (e) {
      _errorMessage = 'Erro ao carregar usuários: $e';
    }
  }
}
