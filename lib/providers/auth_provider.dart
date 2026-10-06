import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/auth_api.dart';
import '../constants/app_constants.dart';
import '../models/auth_model.dart';

/// Logic đăng nhập: gọi `AuthApi`, lưu token qua `flutter_secure_storage`,
/// báo `screens/` cập nhật UI qua `notifyListeners()`.
class AuthProvider with ChangeNotifier {
  AuthProvider({AuthApi? authApi, FlutterSecureStorage? secureStorage})
      : _authApi = authApi ?? AuthApi(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;

  bool loading = false;
  String? errorMessage;

  Future<bool> login(
      {required String username, required String password}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    if (username == AppConstants.demoUsername &&
        password == AppConstants.demoPassword) {
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: 'demo-access-token',
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: 'demo-refresh-token',
      );
      loading = false;
      notifyListeners();
      return true;
    }

    try {
      final response = await _authApi.login(
        LoginRequest(username: username, password: password),
      );
      await _secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: response.refreshToken,
      );
      loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      loading = false;
      errorMessage = _mapError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  String _mapError(DioException e) {
    if (e.response?.statusCode == 401) {
      return AppConstants.invalidCredentialsMessage;
    }
    final serverMessage = e.response?.data is Map
        ? (e.response?.data as Map)['message'] as String?
        : null;
    return serverMessage ?? AppConstants.genericErrorMessage;
  }
}
