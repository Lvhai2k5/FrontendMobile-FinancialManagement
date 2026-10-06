import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

/// Logic + state cho danh sách thông báo. Backend chưa có endpoint
/// `/notifications` nên seed mock tại đây — xem ghi chú ở
/// `family_provider.dart`.
class NotificationProvider with ChangeNotifier {
  NotificationProvider() {
    _seed();
  }

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  void respondToApproval(int id, {required bool approved}) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void _seed() {
    _notifications.addAll(const [
      NotificationModel(
        id: 1,
        kind: NotificationKind.approvalRequest,
        title: 'Giao dịch cần duyệt',
        message:
            'Nguyên vừa tạo giao dịch "Đồ chơi Lego" -450.000 đ, vượt hạn mức cần chấp thuận.',
        timeLabel: '10 phút trước',
        actionable: true,
      ),
      NotificationModel(
        id: 2,
        kind: NotificationKind.thresholdWarning,
        title: 'Cảnh báo hạn mức hũ',
        message:
            'Hũ nhu cầu thiết yếu đã đạt 81.2% định mức tháng này. Hãy cân nhắc các khoản chi sắp tới.',
        timeLabel: '2 giờ trước',
      ),
      NotificationModel(
        id: 3,
        kind: NotificationKind.syncSuccess,
        title: 'Đã đồng bộ giao dịch',
        message:
            'Giao dịch Tiền điện nước 1.200.000 đ đã được Lan ghi nhận thành công vào Hũ thiết yếu.',
        timeLabel: 'Hôm qua',
      ),
    ]);
  }
}
