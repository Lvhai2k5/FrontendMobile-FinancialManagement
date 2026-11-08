/// Kiểm tra dữ liệu đăng ký trước khi gọi API; backend vẫn kiểm tra dữ liệu.
class RegistrationValidators {
  RegistrationValidators._();

  static String? name(String? value) {
    final name = (value ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return 'Vui lòng nhập họ và tên.';
    return RegExp(r"^[\p{L}\p{M}]+(?:[ .'’-][\p{L}\p{M}]+)*$", unicode: true)
            .hasMatch(name)
        ? null
        : 'Nhập họ tên bằng chữ, ví dụ: Nguyễn An.';
  }

  static String? gmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Vui lòng nhập Gmail.';
    const invalid = 'Gmail không đúng định dạng, ví dụ: ten@gmail.com.';
    final parts = email.split('@');
    if (email.length > 254 || parts.length != 2) return invalid;
    final local = parts[0];
    if (local.isEmpty ||
        local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..') ||
        !RegExp(r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~.-]+$").hasMatch(local)) {
      return invalid;
    }
    final labels = parts[1].split('.');
    if (labels.length < 2 ||
        labels.last.length < 2 ||
        labels.any((label) =>
            !RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$')
                .hasMatch(label))) {
      return invalid;
    }
    if (parts[1].toLowerCase() != 'gmail.com') {
      return 'Vui lòng dùng địa chỉ kết thúc bằng @gmail.com.';
    }
    if (!RegExp(r'^[A-Za-z0-9.]+(?:\+[A-Za-z0-9._-]+)?$').hasMatch(local)) {
      return invalid;
    }
    return null;
  }

  static String normalizePhone(String value) {
    final phone = value.replaceAll(RegExp(r'[\s().-]'), '');
    return phone.startsWith('+84') ? '0${phone.substring(3)}' : phone;
  }

  static String? phone(String? value) {
    final phone = normalizePhone(value ?? '');
    if (phone.isEmpty) return 'Vui lòng nhập số điện thoại.';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Số điện thoại cần đúng 10 chữ số (hoặc +84 thay số 0 đầu).';
    }
    return RegExp(r'^0[35789]\d{8}$').hasMatch(phone)
        ? null
        : 'Số di động phải bắt đầu bằng 03, 05, 07, 08 hoặc 09.';
  }

  static String? username(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) return 'Vui lòng nhập tên tài khoản.';
    return RegExp(r'^[A-Za-z0-9._]{3,30}$').hasMatch(username)
        ? null
        : 'Dùng 3–30 ký tự: chữ không dấu, số, dấu chấm hoặc gạch dưới.';
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.trim().isEmpty) return 'Vui lòng nhập mật khẩu.';
    if (password.length < 8) return 'Mật khẩu cần tối thiểu 8 ký tự.';
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu cần có cả chữ và số.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Vui lòng xác nhận mật khẩu.';
    return value != password ? 'Xác nhận mật khẩu không khớp.' : null;
  }
}
