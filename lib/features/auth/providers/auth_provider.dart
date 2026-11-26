import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/erp_api_client.dart';

class ErpUser {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? storeName;

  const ErpUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.storeName,
  });

  String get identifier => email.isNotEmpty ? email : phone;

  factory ErpUser.fromJson(JsonMap json, {String? fallbackStoreName}) {
    final rawStore = (json['store_name'] ?? json['storeName'] ?? '').toString().trim();
    return ErpUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'Admin').toString(),
      storeName: rawStore.isNotEmpty ? rawStore : fallbackStoreName,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  static const _storeNameKey = 'steel_suvidha_store_name';

  ErpUser? _currentUser;
  String _storeName = 'Steel Suvidha';
  String _selectedRole = 'Super Admin';
  bool _isLoading = false;
  String? _errorMessage;

  ErpUser? get currentUser => _currentUser;
  String get storeName => _storeName;
  String get selectedRole => _selectedRole;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _persistStoreName(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _storeName = clean;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeNameKey, clean);
  }

  Future<void> setStoreName(String name) async {
    await _persistStoreName(name);
    notifyListeners();
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
    String? otp,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    final cleanStore =
        storeName.trim().isEmpty ? 'Steel Suvidha' : storeName.trim();
    await _persistStoreName(cleanStore);
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
      );
      _currentUser = user;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        await _persistStoreName(user.storeName!);
      }
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
    String? otp,
    Object? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    if (storeName != null && storeName.trim().isNotEmpty) {
      await _persistStoreName(storeName.trim());
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
      );
      _currentUser = user;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        await _persistStoreName(user.storeName!);
      }
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
      );
      _currentUser = user;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        await _persistStoreName(user.storeName!);
      }
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
      );
      _currentUser = user;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        await _persistStoreName(user.storeName!);
      }
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
    if (savedStore != null && savedStore.trim().isNotEmpty) {
      _storeName = savedStore.trim();
      notifyListeners();
    }

    final token = await ErpApiClient.instance.getToken();
    if (token == null || token.isEmpty) return;
    try {
      final data = await ErpApiClient.instance.get('/api/auth/me');
      final user = ErpUser.fromJson(
        data['user'] as JsonMap,
        fallbackStoreName: _storeName,
      );
      _currentUser = user;
      if (user.storeName != null && user.storeName!.isNotEmpty) {
        await _persistStoreName(user.storeName!);
      }
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