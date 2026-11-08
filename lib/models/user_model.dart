/// Hồ sơ người dùng đang đăng nhập — khớp `GET /api/v1/users/me`.
class UserModel {
  const UserModel({
    required this.personId,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  final int personId;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        personId: (json['personId'] as num?)?.toInt() ?? 0,
        username: json['username'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: json['role'] as String? ?? 'USER',
      );
}
