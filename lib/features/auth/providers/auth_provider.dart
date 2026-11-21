import 'package:flutter/foundation.dart';
import '../../../core/constants/app_roles.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Please enter both credentials and password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      id: 'USR-001',
      name: 'Operator (${role.label})',
      identifier: identifier.trim(),
      role: role,
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
