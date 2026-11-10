import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/transaction_model.dart';
import '../../models/voice_parse_result.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/format_currency.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/inline_picker.dart';

/// Tham số route cho form được điền sẵn (từ giọng nói).
class TransactionFormArgs {
  const TransactionFormArgs({required this.familyId, this.prefill});

  final int? familyId;
  final VoiceParseResult? prefill;
}

/// "Nhập thủ công" — form xác nhận tạo `Transaction` thật; Giọng nói chỉ điền
/// sẵn form này (các kênh khác ở tab Giao dịch chưa có). Danh mục lấy từ gia
/// đình đang chọn; Backend quyết định giao dịch được ghi nhận ngay hay phải
/// chờ Chủ hộ duyệt (vượt ngưỡng cần duyệt).
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.familyId, this.prefill});

  final int? familyId;

  /// Gợi ý từ giọng nói — chỉ điền sẵn, người dùng vẫn phải xem lại và bấm Lưu.
  final VoiceParseResult? prefill;

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
    final prefill = widget.prefill;
    if (prefill != null) {
      _type = prefill.type;
      _contentController.text = prefill.content ?? '';
      final amount = prefill.amount;
      if (amount != null) _amountController.text = formatCurrency(amount);
      _categoryId = prefill.categoryId;
    }
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
    final amount = parseCurrencyInput(_amountController.text);
    if (_saving) return;
    if (content.isEmpty ||
        amount == null ||
        !amount.isFinite ||
        amount <= 0 ||
        amount >= 1e12) {
      _showMessage('Vui lòng nhập đầy đủ nội dung và số tiền hợp lệ.',
          error: true);
      return;
    }
    if (_categoryId == null) {
      _showMessage('Vui lòng chọn danh mục.', error: true);
      return;
    }

    final families = context.read<FamilyProvider>();
    final detail = families.detail(_familyId ?? families.selectedFamilyId);
    if (detail == null ||
        !detail.canWrite ||
        !detail.actionCategories.any((c) => c.id == _categoryId && !c.locked)) {
      _showMessage('Bạn cần quyền Ghi và một danh mục đang mở.', error: true);
      return;
    }
    setState(() => _saving = true);
    final notifications = context.read<NotificationProvider>();
    final result =
        await context.read<TransactionProvider>().addManualTransaction(
              financialCategoryId: _categoryId!,
              content: content,
              amount: amount,
              type: _type,
            );
    if (!mounted) return;
    if (result.error != null) {
      setState(() => _saving = false);
      _showMessage(result.error!, error: true);
      return;
    }
    if (result.queued) {
      Navigator.of(context).pop();
      _showMessage(
          'Đã lưu trên thiết bị. Bạn có thể theo dõi tại mục Đồng bộ giao dịch.');
      return;
    }
    // Cập nhật số dư, hạn mức và thông báo sau khi máy chủ ghi nhận.
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
    final requestedFamilyId = _familyId ?? provider.selectedFamilyId;
    final familyId = families.any((f) => f.familyId == requestedFamilyId)
        ? requestedFamilyId
        : null;
    final detail = provider.detail(familyId);
    final categories = detail?.actionCategories ?? const [];

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
            Text('Tổ ấm',
                style: AppTypography.titleSm
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            InlinePicker<int>(
              placeholder: 'Chọn tổ ấm',
              value: familyId,
              options: {for (final f in families) f.familyId: f.name},
              onChanged: _saving
                  ? null
                  : (id) {
                      if (id == familyId) return;
                      setState(() {
                        _familyId = id;
                        _categoryId = null;
                      });
                    },
            ),
            const SizedBox(height: 16),
            if (familyId == null)
              const _InfoBox('Chọn tổ ấm để xem danh mục.')
            else if (detail?.canWrite != true)
              const _InfoBox('Bạn chưa có quyền Ghi trong tổ ấm này.')
            else ...[
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
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
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
                inputFormatters: const [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 16),
              Text('Danh mục',
                  style: AppTypography.titleSm
                      .copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              if (categories.isEmpty)
                _InfoBox(
                    'Gia đình này chưa có danh mục. Chủ hộ hãy thêm danh mục ở màn Chi tiết gia đình.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in categories)
                      ChoiceChip(
                        label: Text(c.locked ? '${c.name} (khoá)' : c.name),
                        selected: _categoryId == c.id && !c.locked,
                        onSelected: c.locked
                            ? null
                            : (_) => setState(() => _categoryId = c.id),
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: AppTypography.labelMd.copyWith(
                            color: _categoryId == c.id
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
                onPressed: _handleSubmit,
              ),
            ],
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
              AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
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
            Flexible(
              child: Text(label,
                  style: AppTypography.titleSm.copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
