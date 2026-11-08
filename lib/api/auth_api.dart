import 'api_client.dart';
import '../models/auth_model.dart';

/// Gọi endpoint auth theo `TECH-AUTH.md` mục 3. Chỉ gửi/nhận JSON thô,
/// không xử lý lưu token hay điều hướng ở đây.
class AuthApi {
  Future<AuthResponse> login(LoginRequest request) async {
    final res = await apiClient.post('/auth/login', data: request.toJson());
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  /// Tạo tài khoản (chưa kích hoạt) và Backend gửi OTP `REGISTER` tới email.
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    await apiClient.post('/auth/register', data: {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  /// `purpose`: `REGISTER` hoặc `RESET_PASSWORD`.
  Future<void> sendOtp({required String email, required String purpose}) async {
    await apiClient
        .post('/auth/otp/send', data: {'email': email, 'purpose': purpose});
  }

  Future<void> verifyOtp({
    required String email,
    required String purpose,
    required String otp,
  }) async {
    await apiClient.post('/auth/otp/verify',
        data: {'email': email, 'purpose': purpose, 'otp': otp});
  }

  Future<void> forgotPassword({required String email}) async {
    await apiClient.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await apiClient.post('/auth/reset-password',
        data: {'email': email, 'newPassword': newPassword});
  }
}
