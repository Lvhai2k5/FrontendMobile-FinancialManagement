import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

/// Danh sách thông báo — thông báo `actionable` (giao dịch vượt
/// `Threshold(Approve)`) cho phép Chủ hộ Phê duyệt/Từ chối ngay tại đây.
/// Thiết kế theo `finnest_popup_th_ng_b_o`.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Thông báo'),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text('Không có thông báo mới.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final n in notifications) _NotificationCard(notification: n),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Xem tất cả thông báo cũ →',
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  Color get _accent => switch (notification.kind) {
        NotificationKind.approvalRequest => AppColors.primary,
        NotificationKind.thresholdWarning => AppColors.pastelLavender,
        NotificationKind.syncSuccess => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _accent, width: 3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.kind.icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(notification.title, style: AppTypography.titleSm)),
              Text(notification.timeLabel,
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(notification.message,
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
          if (notification.actionable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context
                        .read<NotificationProvider>()
                        .respondToApproval(notification.id, approved: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Phê duyệt'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context
                        .read<NotificationProvider>()
                        .respondToApproval(notification.id, approved: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(color: AppColors.surfaceContainer),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
