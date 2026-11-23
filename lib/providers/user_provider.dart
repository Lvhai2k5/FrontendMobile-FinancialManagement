import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../api/user_api.dart';
import '../models/user_model.dart';
import '../utils/api_error.dart';

/// Hồ sơ người dùng đang đăng nhập + gửi phản ánh hỗ trợ.
class UserProvider with ChangeNotifier {
  UserProvider({UserApi? api}) : _api = api ?? UserApi();

  final UserApi _api;
  UserModel? user;
  int _session = 0;
  List<Map<String, dynamic>> supportTickets = [];
  String? supportTicketsError;
  bool loadingSupportTickets = false;

  Future<void> load() async {
    final session = _session;
    try {
      final loaded = await _api.me();
      if (session != _session) return;
      user = loaded;
      notifyListeners();
    } catch (_) {
      // Màn hình tự hiển thị trạng thái "chưa có dữ liệu".
    }
  }

  Future<String?> updateProfile(
      {required String name, required String phone}) async {
    try {
      user = await _api.updateMe(name: name, phone: phone);
      notifyListeners();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> uploadAvatar(XFile image) async {
    try {
      final bytes = await image.length();
      if (bytes == 0 || bytes > 5 * 1024 * 1024) {
        return 'Ảnh phải có dung lượng tối đa 5 MiB.';
      }
      user = await _api.uploadAvatar(image.path, image.name);
      notifyListeners();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _api.changePassword(currentPassword, newPassword);
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> loadSupportTickets() async {
    loadingSupportTickets = true;
    supportTicketsError = null;
    notifyListeners();
    try {
      supportTickets = await _api.mySupportTickets();
      loadingSupportTickets = false;
      notifyListeners();
      return null;
    } catch (e) {
      supportTicketsError = apiErrorMessage(e);
      loadingSupportTickets = false;
      notifyListeners();
      return supportTicketsError;
    }
  }

  Future<String?> sendSupportTicket(String content) async {
    try {
      await _api.createSupportTicket(content);
      await loadSupportTickets();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  void clear() {
    _session++;
    user = null;
    supportTickets = [];
    supportTicketsError = null;
    loadingSupportTickets = false;
    notifyListeners();
  }
}
