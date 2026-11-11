import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';
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
  final result = await context.read<FamilyProvider>().createFamily(name);
  if (!context.mounted) return;
  if (result.familyId case final id?) {
    Navigator.of(context).pushNamed(AppRoutes.familyDetail, arguments: id);
    showSnack(context, 'Đã tạo gia đình "$name".');
  } else {
    showSnack(context, result.error ?? 'Chưa tạo được gia đình.', error: true);
  }
}

/// Nhập mã mời do Chủ hộ sao chép từ Chi tiết gia đình.
Future<void> promptJoinFamily(BuildContext context) async {
  final code = await showTextInputDialog(
    context,
    title: 'Nhập mã mời',
    hint: 'Dán mã mời của tổ ấm',
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

  double? parse(TextEditingController c) => parseCurrencyInput(c.text);

  Widget field(TextEditingController c, String label,
          {required IconData icon,
          String? hint,
          bool number = true,
          bool last = false}) =>
      Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(label,
                  style: AppTypography.bodyMd.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
            ),
            TextField(
              controller: c,
              style: AppTypography.titleSm
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
              textInputAction:
                  last ? TextInputAction.done : TextInputAction.next,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              textCapitalization: number
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              inputFormatters: number ? const [CurrencyInputFormatter()] : null,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMd.copyWith(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                suffixStyle: AppTypography.titleSm
                    .copyWith(fontSize: 18, color: AppColors.onSurfaceVariant),
                prefixIcon: Icon(icon, size: 26, color: AppColors.primary),
                suffixText: number ? 'đ' : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.surfaceContainer),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      );

  Widget section(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(top: 36, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleSm.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: AppTypography.bodyMd
                    .copyWith(fontSize: 15, color: AppColors.onSurfaceVariant)),
          ],
        ),
      );

  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.pastelBlush,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        Icon(Icons.savings_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Thêm danh mục',
                            style: AppTypography.headlineSm
                                .copyWith(fontSize: 22)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    section(
                        'Thông tin chung', 'Tên và định mức ban đầu của hũ.'),
                    field(name, 'Tên danh mục',
                        icon: Icons.label_outline,
                        hint: 'Ví dụ: Ăn uống',
                        number: false),
                    field(balance, 'Định mức / số dư ban đầu',
                        icon: Icons.account_balance_wallet_outlined,
                        hint: '0',
                        last: true),
                    section('Ngưỡng cảnh báo',
                        'Để trống sẽ dùng giá trị gợi ý theo định mức.'),
                    field(warning, 'Cảnh báo khi chi đến',
                        icon: Icons.warning_amber_rounded,
                        hint: '80% định mức'),
                    field(emergency, 'Khẩn cấp khi chi đến',
                        icon: Icons.error_outline, hint: '100% định mức'),
                    field(approval, 'Cần duyệt khi mỗi lần chi từ',
                        icon: Icons.verified_user_outlined,
                        hint: '0 = không cần duyệt',
                        last: true),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(58),
                        textStyle: AppTypography.titleSm.copyWith(fontSize: 17),
                        side: BorderSide(color: AppColors.surfaceContainer),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text('Huỷ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(54),
                        textStyle: AppTypography.titleSm,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text('Thêm danh mục'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
