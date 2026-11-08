import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/text_input_dialog.dart';
import 'family_actions.dart';

Future<void> addFamilyMember(BuildContext context, int familyId) async {
  final username = await showTextInputDialog(
    context,
    title: 'Thêm thành viên',
    hint: 'Tên tài khoản FinNest',
    message: 'Thành viên mới được cấp quyền Xem và Ghi.',
    confirmLabel: 'Thêm thành viên',
  );
  if (username == null || username.trim().isEmpty || !context.mounted) return;
  await _save(
      context,
      () => context.read<FamilyProvider>().addMember(familyId, username.trim()),
      'Đã thêm thành viên.');
}

class MemberManagementMenu extends StatelessWidget {
  const MemberManagementMenu({
    super.key,
    required this.familyId,
    required this.member,
  });

  final int familyId;
  final FamilyMemberModel member;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        tooltip: 'Quản lý ${member.name}',
        onSelected: (action) => _run(context, action),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'permissions', child: Text('Chỉnh quyền')),
          PopupMenuItem(
              value: 'transfer', child: Text('Chuyển vai trò Chủ hộ')),
          PopupMenuItem(value: 'remove', child: Text('Xóa thành viên')),
        ],
      );

  Future<void> _run(BuildContext context, String action) async {
    final provider = context.read<FamilyProvider>();
    if (action == 'permissions') {
      final permissions = await showDialog<Set<String>>(
        context: context,
        builder: (_) => _PermissionsDialog(member: member),
      );
      if (permissions == null || !context.mounted) return;
      await _save(
          context,
          () => provider.updatePermissions(
              familyId, member.personId, permissions),
          'Đã cập nhật quyền thành viên.');
      return;
    }
    final transfer = action == 'transfer';
    final confirmed = await _confirm(
      context,
      transfer ? 'Chuyển vai trò Chủ hộ' : 'Xóa thành viên',
      transfer
          ? '${member.name} sẽ trở thành Chủ hộ. Bạn sẽ là thành viên có quyền Xem và Ghi.'
          : '${member.name} sẽ mất quyền truy cập tổ ấm này. Các giao dịch đã ghi vẫn được giữ.',
      transfer ? 'Chuyển vai trò' : 'Xóa thành viên',
    );
    if (!confirmed || !context.mounted) return;
    await _save(
      context,
      transfer
          ? () => provider.transferOwnership(familyId, member.personId)
          : () => provider.removeMember(familyId, member.personId),
      transfer ? 'Đã chuyển vai trò Chủ hộ.' : 'Đã xóa thành viên.',
    );
  }
}

class _PermissionsDialog extends StatefulWidget {
  const _PermissionsDialog({required this.member});

  final FamilyMemberModel member;

  @override
  State<_PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<_PermissionsDialog> {
  late final Set<String> _permissions = {...widget.member.permissions};

  static const _options = {
    'READ': ('Xem', 'Xem danh mục, số dư và lịch sử giao dịch.'),
    'WRITE': ('Ghi', 'Tạo và đồng bộ giao dịch.'),
    'APPROVAL': ('Duyệt', 'Duyệt, từ chối giao dịch và mở khóa danh mục.'),
  };

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Quyền của ${widget.member.name}',
            style: AppTypography.headlineSm),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in _options.entries)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _permissions.contains(entry.key),
                title: Text(entry.value.$1),
                subtitle: Text(entry.value.$2),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _permissions.add(entry.key);
                  } else {
                    _permissions.remove(entry.key);
                  }
                }),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(context, _permissions),
            child: const Text('Lưu quyền'),
          ),
        ],
      );
}

Future<void> changeCategoryLock(
    BuildContext context, CategoryAction category) async {
  final label = category.locked ? 'Mở khóa danh mục' : 'Khóa danh mục';
  final confirmed = await _confirm(
    context,
    label,
    category.locked
        ? 'Thành viên có quyền Ghi có thể tạo giao dịch trong hũ ${category.name}.'
        : 'Tạm dừng ghi giao dịch mới trong hũ ${category.name}.',
    label,
  );
  if (!confirmed || !context.mounted) return;
  await _save(
      context,
      () => context
          .read<FamilyProvider>()
          .setCategoryLocked(category.id, !category.locked),
      category.locked ? 'Đã mở khóa danh mục.' : 'Đã khóa danh mục.');
}

Future<bool> _confirm(BuildContext context, String title, String message,
        String label) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(title, style: AppTypography.headlineSm),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(label),
          ),
        ],
      ),
    ) ??
    false;

Future<void> _save(BuildContext context, Future<String?> Function() action,
    String success) async {
  final notifications = context.read<NotificationProvider>();
  final transactions = context.read<TransactionProvider>();
  final error = await action();
  if (!context.mounted) return;
  showSnack(context, error ?? success, error: error != null);
  if (error == null) {
    await Future.wait([notifications.load(), transactions.load()]);
  }
}
