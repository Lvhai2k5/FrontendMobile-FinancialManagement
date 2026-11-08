import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/text_input_dialog.dart';

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.error : AppColors.secondary,
    ),
  );
}

/// Hỏi tên rồi tạo gia đình mới qua Backend; người tạo mặc định là Chủ hộ.
Future<void> promptCreateFamily(BuildContext context) async {
  final name = await showTextInputDialog(
    context,
    title: 'Tạo gia đình mới',
    hint: 'Ví dụ: Gia đình Minh & Lan',
    confirmLabel: 'Tạo gia đình',
  );
  if (name == null || name.isEmpty || !context.mounted) return;
  final error = await context.read<FamilyProvider>().createFamily(name);
  if (!context.mounted) return;
  showSnack(context, error ?? 'Đã tạo gia đình "$name".', error: error != null);
}

/// Nhập mã mời dạng `#FN-<số>` để tham gia gia đình có sẵn.
Future<void> promptJoinFamily(BuildContext context) async {
  final code = await showTextInputDialog(
    context,
    title: 'Nhập mã mời',
    hint: '#FN-1',
    message: 'Nhờ Chủ hộ gửi mã gia đình (hiện ở màn Chi tiết gia đình).',
    confirmLabel: 'Gia nhập',
  );
  if (code == null || code.isEmpty || !context.mounted) return;
  final family = context.read<FamilyProvider>();
  final transactions = context.read<TransactionProvider>();
  final error = await family.joinFamily(code);
  if (!context.mounted) return;
  if (error == null) await transactions.load();
  if (!context.mounted) return;
  showSnack(context, error ?? 'Đã gia nhập gia đình.', error: error != null);
}

/// Biểu mẫu thêm danh mục (hũ) tài chính — chỉ Chủ hộ gọi được (Backend kiểm tra).
Future<void> promptCreateCategory(BuildContext context, int familyId) async {
  final name = TextEditingController();
  final balance = TextEditingController();
  final warning = TextEditingController();
  final emergency = TextEditingController();
  final approval = TextEditingController();

  double? parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll('.', '').replaceAll(',', ''));

  Widget field(TextEditingController c, String label, {bool number = true}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Thêm danh mục', style: AppTypography.headlineSm),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field(name, 'Tên danh mục (hũ)', number: false),
            field(balance, 'Định mức / số dư ban đầu (đ)'),
            field(warning, 'Ngưỡng cảnh báo (đ)'),
            field(emergency, 'Ngưỡng khẩn cấp (đ)'),
            field(approval, 'Ngưỡng cần duyệt mỗi lần (đ)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Thêm'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final initial = parse(balance);
  if (name.text.trim().isEmpty || initial == null) {
    showSnack(context, 'Vui lòng nhập tên và định mức hợp lệ.', error: true);
    return;
  }
  final error = await context.read<FamilyProvider>().createCategory(
        familyId,
        name: name.text.trim(),
        initialBalance: initial,
        amountOfWarning: parse(warning) ?? initial * 0.8,
        amountOfEmergency: parse(emergency) ?? initial,
        amountOfApproval: parse(approval) ?? 0,
      );
  if (!context.mounted) return;
  showSnack(context, error ?? 'Đã thêm danh mục.', error: error != null);
}

/// Hiện mã mời để Chủ hộ gửi cho người thân (họ nhập ở "Nhập mã mời").
Future<void> showInviteCode(BuildContext context, String code) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Mời thành viên', style: AppTypography.headlineSm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Gửi mã này cho người thân, họ chọn "Nhập mã mời" để gia nhập:',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SelectableText(code, style: AppTypography.brandTitle),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            if (context.mounted) showSnack(context, 'Đã sao chép mã $code');
          },
          child: const Text('Sao chép'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}
