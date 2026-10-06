import 'package:flutter/material.dart';

/// Loại thông báo hiển thị trên màn "Thông báo" — quyết định icon/màu, không
/// phải enum nghiệp vụ trên diagram (Backend chưa có endpoint
/// `/notifications`).
enum NotificationKind { approvalRequest, thresholdWarning, syncSuccess }

extension NotificationKindVisual on NotificationKind {
  IconData get icon => switch (this) {
        NotificationKind.approvalRequest => Icons.hourglass_top,
        NotificationKind.thresholdWarning => Icons.pie_chart_outline,
        NotificationKind.syncSuccess => Icons.sync_alt,
      };
}

/// 1 thông báo trong danh sách — có thể yêu cầu hành động duyệt/từ chối
/// (dành cho Chủ hộ khi giao dịch vượt `Threshold(Approve)`).
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.actionable = false,
  });

  final int id;
  final NotificationKind kind;
  final String title;
  final String message;
  final String timeLabel;
  final bool actionable;
}
