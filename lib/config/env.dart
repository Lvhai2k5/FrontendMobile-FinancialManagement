import 'package:flutter/foundation.dart' show kIsWeb;

/// Đọc cấu hình môi trường truyền vào lúc build qua `--dart-define`.
/// Không hardcode URL backend ở nơi khác trong app.
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        kIsWeb ? 'http://localhost:8081/api/v1' : 'http:// 192.168.32.211:8081/api/v1',
  );
}
