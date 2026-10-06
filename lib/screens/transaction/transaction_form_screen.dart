import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// "Nhập thủ công" — cách duy nhất tạo `Transaction` thật (3 kênh còn lại ở
/// tab Giao dịch chưa có trong phạm vi Backend). Không có thiết kế Stitch
/// riêng cho biểu mẫu này nên dựng theo đúng phong cách input/nút chung.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _contentController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _category = 'Hũ thiết yếu';

  static const _categories = [
    'Hũ thiết yếu',
    'Hũ giáo dục',
    'Hũ tiết kiệm',
    'Hũ hưởng thụ',
    'Hũ khẩn cấp & y tế',
    'Hũ cho đi',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final content = _contentController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll('.', ''));
    if (content.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ nội dung và số tiền hợp lệ.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<TransactionProvider>().addManualTransaction(
          content: content,
          amount: amount,
          type: _type,
          categoryName: _category,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã ghi nhận giao dịch, chờ duyệt.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: _TypeToggle(
                  label: 'Chi tiêu',
                  icon: Icons.arrow_upward,
                  selected: _type == TransactionType.expense,
                  onTap: () => setState(() => _type = TransactionType.expense),
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
          Text('Danh mục', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _categories)
                ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLow,
                  labelStyle: AppTypography.labelSm.copyWith(
                      color: _category == c ? Colors.white : AppColors.onSurfaceVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Lưu giao dịch',
            trailingIcon: Icons.check,
            backgroundColor: AppColors.primaryContainer,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle(
      {required this.label, required this.icon, required this.selected, required this.onTap});

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
          color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.titleSm
                    .copyWith(color: selected ? Colors.white : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
