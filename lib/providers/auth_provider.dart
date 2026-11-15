import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/auth_api.dart';
import '../constants/app_constants.dart';
import '../models/auth_model.dart';
import '../services/google_identity_provider.dart';

/// Logic đăng nhập: gọi `AuthApi`, lưu token qua `flutter_secure_storage`,
/// báo `screens/` cập nhật UI qua `notifyListeners()`.
class AuthProvider with ChangeNotifier {
  AuthProvider({
    AuthApi? authApi,
    FlutterSecureStorage? secureStorage,
    GoogleIdentityProvider? googleIdentityProvider,
  })  : _authApi = authApi ?? AuthApi(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleIdentityProvider =
            googleIdentityProvider ?? GoogleSignInIdentityProvider();

  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;
  final GoogleIdentityProvider _googleIdentityProvider;

  bool loading = false;
  String? errorMessage;

  Future<bool> login(
      {required String username, required String password}) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authApi.login(
        LoginRequest(username: username, password: password),
      );
      await _storeTokens(response);
      return true;
    } on DioException catch (e) {
      errorMessage = _mapError(e);
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = AppConstants.genericErrorMessage;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final idToken = await _googleIdentityProvider.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        errorMessage = 'Google không trả về mã xác thực. Vui lòng thử lại.';
        return false;
      }
      final response = await _authApi.loginWithGoogle(
        GoogleLoginRequest(idToken: idToken),
      );
      await _storeTokens(response);
      return true;
    } on DioException catch (e) {
      errorMessage = _mapError(e);
      return false;
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') return false;
      errorMessage = e.code.name == 'clientConfigurationError'
          ? 'Đăng nhập Google chưa được cấu hình cho ứng dụng này.'
          : 'Không thể xác thực Google. Vui lòng thử lại.';
      return false;
    } on GoogleAuthConfigurationException {
      errorMessage =
          'Thiếu GOOGLE_SERVER_CLIENT_ID. Hãy cấu hình OAuth client ID để đăng nhập Google.';
      return false;
    } catch (_) {
      errorMessage = 'Không thể đăng nhập bằng Google. Vui lòng thử lại.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _storeTokens(AuthResponse response) async {
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: response.accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: response.refreshToken,
    );
  }

  /// Đăng ký: trả về `null` nếu thành công, ngược lại là message lỗi để hiển thị.
  Future<String?> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) =>
      _run(() => _authApi.register(
          name: name,
          username: username,
          email: email,
          phone: phone,
          password: password));

  Future<String?> sendOtp({required String email, required String purpose}) =>
      _run(() => _authApi.sendOtp(email: email, purpose: purpose));

  Future<String?> verifyOtp({
    required String email,
    required String purpose,
    required String otp,
  }) =>
      _run(() => _authApi.verifyOtp(email: email, purpose: purpose, otp: otp));

  Future<String?> forgotPassword({required String email}) =>
      _run(() => _authApi.forgotPassword(email: email));

  Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) =>
      _run(
          () => _authApi.resetPassword(email: email, newPassword: newPassword));

  /// Chạy 1 thao tác gọi API, bật/tắt `loading`, trả message lỗi (hoặc `null`).
  Future<String?> _run(Future<void> Function() action) async {
    loading = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on DioException catch (e) {
      return _mapError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  String _mapError(DioException e) {
    if (e.response == null) {
      return AppConstants.networkErrorMessage;
    }
    final serverMessage = e.response?.data is Map
        ? (e.response?.data as Map)['message'] as String?
        : null;
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }
    if (e.response?.statusCode == 401) {
      return AppConstants.invalidCredentialsMessage;
    }
    return AppConstants.genericErrorMessage;
  }
}
