/// Hằng số dùng chung toàn app — đặt tên khớp với `constants/`/`enums/` bên
/// Backend và Web khi cùng nghiệp vụ, theo quy ước ở `SKILLS-FRONTEND-MOBILE.md`.
class AppConstants {
  AppConstants._();

  /// Key lưu token trong `flutter_secure_storage`.
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';

  /// Message lỗi mặc định khi không đọc được lỗi cụ thể từ Backend.
  static const String genericErrorMessage = 'Có lỗi xảy ra, vui lòng thử lại.';
  static const String invalidCredentialsMessage =
      'Tên tài khoản hoặc mật khẩu không đúng.';

  /// Tài khoản demo dùng để xem trước toàn bộ app khi Backend chưa sẵn sàng —
  /// `AuthProvider.login()` nhận diện đúng cặp này thì bỏ qua gọi API thật.
  /// Xoá hằng số này (và nhánh xử lý tương ứng) khi Backend đã có endpoint
  /// `/auth/login` thật để test.
  static const String demoUsername = 'admin';
  static const String demoPassword = 'Levuhai2@5';
}
