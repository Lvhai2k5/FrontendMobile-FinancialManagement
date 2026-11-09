import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';

/// Danh sách thông báo — thông báo `actionable` (giao dịch vượt
/// `Threshold(Approve)`) cho phép Chủ hộ Phê duyệt/Từ chối ngay tại đây.
/// Thiết kế theo `finnest_popup_th_ng_b_o`.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _NotifFilter { all, transaction, threshold }

class _NotificationsScreenState extends State<NotificationsScreen> {
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();
    // Mở màn hình là lấy thông báo mới nhất từ Backend.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<NotificationProvider>().load());
  }

  bool _matches(NotificationModel n) => switch (_filter) {
        _NotifFilter.all => true,
        _NotifFilter.transaction => n.kind != NotificationKind.thresholdWarning,
        _NotifFilter.threshold => n.kind == NotificationKind.thresholdWarning,
      };

  Widget _chip(String label, _NotifFilter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: AppTypography.labelMd.copyWith(
            color: selected ? Colors.white : AppColors.onSurfaceVariant),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<NotificationProvider>().notifications;
    final notifications = all.where(_matches).toList();
    final txCount =
        all.where((n) => n.kind != NotificationKind.thresholdWarning).length;
    final thCount =
        all.where((n) => n.kind == NotificationKind.thresholdWarning).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Thông báo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _chip('Tất cả (${all.length})', _NotifFilter.all),
                _chip('Giao dịch ($txCount)', _NotifFilter.transaction),
                _chip('Hạn mức ($thCount)', _NotifFilter.threshold),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text('Không có thông báo mới.',
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.outline)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      for (final n in notifications)
                        _NotificationCard(notification: n),
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
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final NotificationModel notification;

  /// Chủ hộ duyệt/từ chối qua Backend, rồi tải lại số dư + giao dịch.
  Future<void> _respond(BuildContext context, {required bool approved}) async {
    final notifications = context.read<NotificationProvider>();
    final families = context.read<FamilyProvider>();
    final transactions = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final error = await notifications.respondToApproval(notification.id,
        approved: approved);
    if (error == null) {
      await Future.wait([families.load(), transactions.load()]);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(error ??
            (approved ? 'Đã phê duyệt giao dịch.' : 'Đã từ chối giao dịch.')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error == null ? AppColors.secondary : AppColors.error,
      ),
    );
  }

  Color get _accent => switch (notification.kind) {
        NotificationKind.approvalRequest => AppColors.primary,
        NotificationKind.thresholdWarning => AppColors.primary,
        NotificationKind.syncSuccess => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final isThresholdWarning =
        notification.kind == NotificationKind.thresholdWarning;
    final title =
        isThresholdWarning && notification.title == 'Cảnh báo hạn mức hũ'
            ? 'Cảnh báo hạn mức danh mục'
            : notification.title;
    final message = isThresholdWarning && notification.message.startsWith('Hũ ')
        ? notification.message.replaceFirst('Hũ ', 'Danh mục ')
        : notification.message;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _accent, width: 4)),
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
                child: Icon(notification.kind.icon,
                    size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: AppTypography.titleSm)),
              Text(notification.timeLabel,
                  style:
                      AppTypography.labelSm.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurfaceVariant)),
          if (notification.actionable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _respond(context, approved: true),
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
                    onPressed: () => _respond(context, approved: false),
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
