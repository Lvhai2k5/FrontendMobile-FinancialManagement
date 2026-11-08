import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/format_currency.dart';

class OfflineQueuePanel extends StatelessWidget {
  const OfflineQueuePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<TransactionProvider>();
    if (queue.pending.isEmpty && queue.syncError == null) {
      return const SizedBox.shrink();
    }
    return Card(
      color: AppColors.surfaceContainerLowest,
      margin: const EdgeInsets.only(top: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.cloud_upload_outlined),
        title: Text('Đồng bộ giao dịch', style: AppTypography.titleSm),
        subtitle: Text(queue.syncing
            ? 'Đang đồng bộ…'
            : '${queue.pending.length} giao dịch đang lưu trên thiết bị'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (queue.syncError case final message?)
            Text(message, style: AppTypography.bodySm),
          for (final item in queue.pending)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.content),
              subtitle: Text(
                  '${formatCurrency(item.amount)} đ · ${item.error ?? 'Chờ đồng bộ'}'),
              trailing: IconButton(
                tooltip: 'Bỏ bản lưu ${item.content}',
                icon: const Icon(Icons.delete_outline),
                onPressed:
                    queue.syncing ? null : () => _discard(context, item.id),
              ),
            ),
          if (queue.pending.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.sync),
                onPressed: queue.syncing ? null : () => _sync(context),
                label: const Text('Đồng bộ ngay'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sync(BuildContext context) async {
    final queue = context.read<TransactionProvider>();
    final families = context.read<FamilyProvider>();
    final notifications = context.read<NotificationProvider>();
    final count = await queue.syncPending(retryRejected: true);
    if (count == 0 || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã đồng bộ $count giao dịch.')),
    );
    await Future.wait([families.load(), notifications.load()]);
  }

  Future<void> _discard(BuildContext context, String id) async {
    final queue = context.read<TransactionProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ bản lưu trên thiết bị?'),
        content: const Text('Bản lưu này sẽ được gỡ khỏi hàng đợi đồng bộ.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Bỏ bản lưu')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await queue.discardPending(id);
  }
}
