/// Payload gửi lên `POST /api/v1/auth/login`.
/// Field khớp `Account.username`/`Account.password` — xem
/// `BUSINESS-REQUIREMENTS.md` mục 4.2.
class LoginRequest {
  LoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Response trả về từ `POST /api/v1/auth/login` — cặp access/refresh token
/// theo `TECH-AUTH.md` mục 2.
class AuthResponse {
  AuthResponse({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
