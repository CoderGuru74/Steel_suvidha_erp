import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/erp_api_client.dart';

class ErpUser {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String storeName;
  final String rolePin;

  const ErpUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.storeName = 'Steel Suvidha',
    this.rolePin = '1234',
  });

  String get identifier => email.isNotEmpty ? email : phone;

  factory ErpUser.fromJson(
    JsonMap json, {
    String fallbackStoreName = 'Steel Suvidha',
    String fallbackRolePin = '1234',
  }) {
    final rawStore =
        (json['store_name'] ?? json['storeName'] ?? '').toString().trim();
    final rawPin =
        (json['role_pin'] ?? json['rolePin'] ?? '').toString().trim();

    return ErpUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'Admin').toString(),
      storeName: rawStore.isNotEmpty ? rawStore : fallbackStoreName,
      rolePin: rawPin.isNotEmpty ? rawPin : fallbackRolePin,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  static const _storeNameKey = 'steel_suvidha_store_name';
  static const _rolePinKey = 'steel_suvidha_role_pin';

  ErpUser? _currentUser;
  String _storeName = 'Steel Suvidha';
  String _rolePin = '1234';
  String _selectedRole = 'Admin';
  bool _isLoading = false;
  String? _errorMessage;

  ErpUser? get currentUser => _currentUser;

  String get storeName =>
      (_currentUser?.storeName.isNotEmpty ?? false)
          ? _currentUser!.storeName
          : _storeName;

  String get rolePin =>
      (_currentUser?.rolePin.isNotEmpty ?? false)
          ? _currentUser!.rolePin
          : _rolePin;

  String get selectedRole => _selectedRole;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _persistStoreAndPin({
    String? storeName,
    String? rolePin,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (storeName != null && storeName.trim().isNotEmpty) {
      final cleanStore = storeName.trim();
      _storeName = cleanStore;
      await prefs.setString(_storeNameKey, cleanStore);
    }
    if (rolePin != null && rolePin.trim().isNotEmpty) {
      final cleanPin = rolePin.trim();
      _rolePin = cleanPin;
      await prefs.setString(_rolePinKey, cleanPin);
    }
  }

  Future<void> setStoreName(String name) async {
    await _persistStoreAndPin(storeName: name);
    notifyListeners();
  }

  Future<bool> saveStoreSetup({
    required String storeName,
    required String rolePin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final cleanStore = storeName.trim();
    final cleanPin = rolePin.trim().isEmpty ? _rolePin : rolePin.trim();

    try {
      final data = await ErpApiClient.instance.post(
        '/api/auth/store-setup',
        <String, dynamic>{
          'storeName': cleanStore,
          'rolePin': cleanPin,
        },
      );
      _currentUser = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: cleanStore,
        fallbackRolePin: cleanPin,
      );
      await _persistStoreAndPin(storeName: cleanStore, rolePin: cleanPin);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatRole(Object? role) {
    if (role == null) return _selectedRole;
    final raw = role.toString().trim();
    if (raw.isEmpty) return _selectedRole;
    final dotIndex = raw.lastIndexOf('.');
    return dotIndex != -1 ? raw.substring(dotIndex + 1) : raw;
  }

  void setSelectedRole(Object? role) {
    _selectedRole = _formatRole(role);
    notifyListeners();
  }

  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ErpApiClient.instance.post(
        '/api/auth/send-otp',
        <String, dynamic>{'email': email.trim()},
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ErpApiClient.instance.post(
        '/api/auth/verify-otp',
        <String, dynamic>{
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );
      return res['verified'] == true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerStore({
    required String storeName,
    String? ownerName,
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? rolePin,
    String? otp,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    final cleanStore =
        storeName.trim().isEmpty ? 'Steel Suvidha' : storeName.trim();
    final cleanPin =
        (rolePin != null && rolePin.trim().isNotEmpty) ? rolePin.trim() : _rolePin;
    await _persistStoreAndPin(storeName: cleanStore, rolePin: cleanPin);
    notifyListeners();

    try {
      final resolvedEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'admin_${DateTime.now().millisecondsSinceEpoch}@steelsuvidha.in';
      final resolvedPassword =
          (password != null && password.trim().isNotEmpty)
              ? password.trim()
              : 'Admin@1234';
      final resolvedName = (fullName != null && fullName.trim().isNotEmpty)
          ? fullName.trim()
          : ((ownerName != null && ownerName.trim().isNotEmpty)
              ? ownerName.trim()
              : 'Rupesh Raj');
      final resolvedRole = _formatRole(role);

      final payload = <String, dynamic>{
        'fullName': resolvedName,
        'email': resolvedEmail,
        'phone': (phone ?? '').trim(),
        'password': resolvedPassword,
        'role': resolvedRole,
        'storeName': cleanStore,
        'rolePin': cleanPin,
      };
      if (otp != null && otp.trim().isNotEmpty) {
        payload['otp'] = otp.trim();
      }

      final data = await ErpApiClient.instance.post(
        '/api/auth/register',
        payload,
      );
      await ErpApiClient.instance.saveToken(data['token'] as String);
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: cleanStore,
        fallbackRolePin: cleanPin,
      );
      _currentUser = user;
      await _persistStoreAndPin(
        storeName: user.storeName,
        rolePin: user.rolePin,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? storeName,
    String? rolePin,
    String? otp,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (storeName != null && storeName.trim().isNotEmpty) {
      await _persistStoreAndPin(storeName: storeName.trim());
    }
    if (rolePin != null && rolePin.trim().isNotEmpty) {
      await _persistStoreAndPin(rolePin: rolePin.trim());
    }
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': _formatRole(role),
        'storeName': _storeName,
        'rolePin': _rolePin,
      };
      if (otp != null && otp.trim().isNotEmpty) {
        payload['otp'] = otp.trim();
      }

      final data = await ErpApiClient.instance.post(
        '/api/auth/register',
        payload,
      );
      await ErpApiClient.instance.saveToken(data['token'] as String);
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: _storeName,
        fallbackRolePin: _rolePin,
      );
      _currentUser = user;
      await _persistStoreAndPin(
        storeName: user.storeName,
        rolePin: user.rolePin,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    String? email,
    String? identifier,
    required String password,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (role != null) {
      _selectedRole = _formatRole(role);
    }
    notifyListeners();

    try {
      final resolvedIdentifier = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : (identifier ?? '').trim();

      final data = await ErpApiClient.instance.post(
        '/api/auth/login',
        <String, dynamic>{
          'email': resolvedIdentifier,
          'password': password,
        },
      );
      await ErpApiClient.instance.saveToken(data['token'] as String);
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: _storeName,
        fallbackRolePin: _rolePin,
      );
      _currentUser = user;
      await _persistStoreAndPin(
        storeName: user.storeName,
        rolePin: user.rolePin,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithOtp({
    required String email,
    required String otp,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (role != null) {
      _selectedRole = _formatRole(role);
    }
    notifyListeners();

    try {
      final data = await ErpApiClient.instance.post(
        '/api/auth/login-otp',
        <String, dynamic>{
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );
      await ErpApiClient.instance.saveToken(data['token'] as String);
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: _storeName,
        fallbackRolePin: _rolePin,
      );
      _currentUser = user;
      await _persistStoreAndPin(
        storeName: user.storeName,
        rolePin: user.rolePin,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ErpApiClient.instance.post(
        '/api/auth/reset-password',
        <String, dynamic>{
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword.trim(),
        },
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStore = prefs.getString(_storeNameKey);
    final savedPin = prefs.getString(_rolePinKey);
    if (savedStore != null && savedStore.trim().isNotEmpty) {
      _storeName = savedStore.trim();
    }
    if (savedPin != null && savedPin.trim().isNotEmpty) {
      _rolePin = savedPin.trim();
    }
    notifyListeners();

    final token = await ErpApiClient.instance.getToken();
    if (token == null || token.isEmpty) return;
    try {
      final data = await ErpApiClient.instance.get('/api/auth/me');
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: _storeName,
        fallbackRolePin: _rolePin,
      );
      _currentUser = user;
      await _persistStoreAndPin(
        storeName: user.storeName,
        rolePin: user.rolePin,
      );
      notifyListeners();
    } catch (_) {
      await ErpApiClient.instance.clearToken();
    }
  }

  Future<void> logout() async {
    await ErpApiClient.instance.clearToken();
    _currentUser = null;
    notifyListeners();
  }
}