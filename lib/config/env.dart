/// Đọc cấu hình môi trường truyền vào lúc build qua `--dart-define`.
/// Không hardcode URL backend ở nơi khác trong app.
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );
}
