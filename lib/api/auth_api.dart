import 'api_client.dart';
import '../models/auth_model.dart';

/// Gọi endpoint auth theo `TECH-AUTH.md` mục 3. Chỉ gửi/nhận JSON thô,
/// không xử lý lưu token hay điều hướng ở đây.
class AuthApi {
  Future<AuthResponse> login(LoginRequest request) async {
    final res = await apiClient.post('/auth/login', data: request.toJson());
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
