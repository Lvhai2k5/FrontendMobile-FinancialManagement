import 'package:flutter/foundation.dart';

import '../api/notification_api.dart';
import '../api/transaction_api.dart';
import '../models/notification_model.dart';
import '../utils/api_error.dart';

/// Thông báo (giao dịch cần duyệt, cảnh báo hạn mức) lấy từ Backend.
class NotificationProvider with ChangeNotifier {
  NotificationProvider({NotificationApi? api, TransactionApi? transactionApi})
      : _api = api ?? NotificationApi(),
        _transactionApi = transactionApi ?? TransactionApi();

  final NotificationApi _api;
  final TransactionApi _transactionApi;
  final List<NotificationModel> _notifications = [];

  int _loadVersion = 0;
  bool loading = false;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  Future<void> load() async {
    final version = ++_loadVersion;
    loading = true;
    notifyListeners();
    try {
      final items = await _api.list();
      if (version != _loadVersion) return;
      _notifications
        ..clear()
        ..addAll(items);
    } catch (_) {
      // Giữ danh sách cũ; thông báo không quan trọng bằng chặn UI.
    } finally {
      if (version == _loadVersion) {
        loading = false;
        notifyListeners();
      }
    }
  }

  /// Chủ hộ duyệt/từ chối giao dịch từ thông báo (`id` = transactionId).
  /// Trả `null` nếu thành công, ngược lại là message lỗi.
  Future<String?> respondToApproval(int id, {required bool approved}) async {
    try {
      if (approved) {
        await _transactionApi.approve(id);
      } else {
        await _transactionApi.reject(id);
      }
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  void clear() {
    _loadVersion++;
    loading = false;
    _notifications.clear();
    notifyListeners();
  }
}
