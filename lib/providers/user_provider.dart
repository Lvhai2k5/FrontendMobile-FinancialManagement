import 'package:flutter/foundation.dart';

import '../api/user_api.dart';
import '../models/user_model.dart';
import '../utils/api_error.dart';

/// Hồ sơ người dùng đang đăng nhập + gửi phản ánh hỗ trợ.
class UserProvider with ChangeNotifier {
  UserProvider({UserApi? api}) : _api = api ?? UserApi();

  final UserApi _api;
  UserModel? user;

  Future<void> load() async {
    try {
      user = await _api.me();
      notifyListeners();
    } catch (_) {
      // Màn hình tự hiển thị trạng thái "chưa có dữ liệu".
    }
  }

  Future<String?> updateProfile(
      {required String name,
      required String phone,
      required String email}) async {
    try {
      user = await _api.updateMe(name: name, phone: phone, email: email);
      notifyListeners();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> sendSupportTicket(String content) async {
    try {
      await _api.createSupportTicket(content);
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  void clear() {
    user = null;
    notifyListeners();
  }
}
