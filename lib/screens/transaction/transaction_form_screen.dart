import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// "Nhập thủ công" — cách duy nhất tạo `Transaction` thật (3 kênh còn lại ở
/// tab Giao dịch chưa có trong phạm vi Backend). Danh mục (hũ) lấy từ gia
/// đình đang chọn; Backend quyết định giao dịch được ghi nhận ngay hay phải
/// chờ Chủ hộ duyệt (vượt ngưỡng cần duyệt).
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.familyId});

  final int? familyId;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _contentController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  int? _familyId;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _familyId =
        widget.familyId ?? context.read<FamilyProvider>().selectedFamilyId;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.secondary,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final content = _contentController.text.trim();
    final amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', ''));
    if (content.isEmpty || amount == null || amount <= 0) {
      _showMessage('Vui lòng nhập đầy đủ nội dung và số tiền hợp lệ.',
          error: true);
      return;
    }
    if (_categoryId == null) {
      _showMessage('Vui lòng chọn danh mục (hũ).', error: true);
      return;
    }

    setState(() => _saving = true);
    final families = context.read<FamilyProvider>();
    final notifications = context.read<NotificationProvider>();
    final result =
        await context.read<TransactionProvider>().addManualTransaction(
              financialCategoryId: _categoryId!,
              content: content,
              amount: amount,
              type: _type,
            );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result.error != null) {
      _showMessage(result.error!, error: true);
      return;
    }
    // Số dư/hạn mức/thông báo đổi theo giao dịch mới -> tải lại từ Backend.
    await families.load();
    await notifications.load();
    if (!mounted) return;
    final pending = result.created?.status == TransactionStatus.pend;
    Navigator.of(context).pop();
    _showMessage(pending
        ? 'Giao dịch vượt hạn mức cần duyệt, đã gửi chờ Chủ hộ.'
        : 'Đã ghi nhận giao dịch.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final families = provider.families;
    final detail = provider.detail(_familyId);
    final categories = detail?.categories ?? const <FinancialCategoryModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Nhập thủ công'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (families.isEmpty)
            _InfoBox(
                'Bạn chưa thuộc gia đình nào. Hãy tạo gia đình hoặc nhập mã mời ở tab Gia đình trước khi ghi giao dịch.')
          else ...[
            if (families.length > 1) ...[
              Text('Gia đình',
                  style: AppTypography.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in families)
                    ChoiceChip(
                      label: Text(f.name),
                      selected: _familyId == f.familyId,
                      onSelected: (_) => setState(() {
                        _familyId = f.familyId;
                        _categoryId = null;
                      }),
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceContainerLow,
                      labelStyle: AppTypography.labelSm.copyWith(
                          color: _familyId == f.familyId
                              ? Colors.white
                              : AppColors.onSurfaceVariant),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _TypeToggle(
                    label: 'Chi tiêu',
                    icon: Icons.arrow_upward,
                    selected: _type == TransactionType.expense,
                    onTap: () =>
                        setState(() => _type = TransactionType.expense),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeToggle(
                    label: 'Thu nhập',
                    icon: Icons.arrow_downward,
                    selected: _type == TransactionType.income,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Nội dung',
              controller: _contentController,
              hintText: 'Ví dụ: Siêu thị WinMart',
              prefixIcon: Icons.edit_note,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Số tiền',
              controller: _amountController,
              hintText: '0',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('Danh mục',
                style: AppTypography.labelMd
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              _InfoBox(
                  'Gia đình này chưa có danh mục (hũ). Chủ hộ hãy thêm danh mục ở màn Chi tiết gia đình.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(c.status == CategoryStatus.locked
                          ? '${c.name} (khoá)'
                          : c.name),
                      selected: _categoryId == c.financialCategoryId,
                      onSelected: (_) =>
                          setState(() => _categoryId = c.financialCategoryId),
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceContainerLow,
                      labelStyle: AppTypography.labelSm.copyWith(
                          color: _categoryId == c.financialCategoryId
                              ? Colors.white
                              : AppColors.onSurfaceVariant),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                      side: BorderSide.none,
                    ),
                ],
              ),
            const SizedBox(height: 24),
            AppButton(
              label: _saving ? 'Đang lưu...' : 'Lưu giao dịch',
              trailingIcon: _saving ? null : Icons.check,
              backgroundColor: AppColors.primaryContainer,
              onPressed: _saving ? () {} : _handleSubmit,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style:
              AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.titleSm.copyWith(
                    color:
                        selected ? Colors.white : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
