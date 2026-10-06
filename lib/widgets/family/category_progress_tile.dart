import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../utils/format_currency.dart';

IconData categoryIcon(String name) {
  if (name.contains('thiết yếu')) return Icons.shopping_basket_outlined;
  if (name.contains('Giáo dục')) return Icons.school_outlined;
  if (name.contains('Tiết kiệm')) return Icons.savings_outlined;
  if (name.contains('giải trí') || name.contains('Hưởng thụ')) {
    return Icons.local_cafe_outlined;
  }
  if (name.contains('khẩn cấp') || name.contains('y tế')) {
    return Icons.health_and_safety_outlined;
  }
  if (name.contains('Cho đi') || name.contains('biếu tặng')) {
    return Icons.volunteer_activism_outlined;
  }
  return Icons.account_balance_wallet_outlined;
}

/// 1 dòng "hũ chi tiêu" với thanh tiến độ chi/định mức — dùng chung ở tab
/// Tổng quan và màn Chi tiết gia đình. Widget thuần túy: chỉ nhận
/// [category] và callback [onTap] tuỳ nơi gọi (mở cấu hình hạn mức hay
/// không).
class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    super.key,
    required this.category,
    this.onTap,
    this.index,
  });

  final FinancialCategoryModel category;
  final VoidCallback? onTap;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final locked = category.status == CategoryStatus.locked;
    final ratio = category.usageRatio.clamp(0.0, 1.0);
    final barColor = locked
        ? AppColors.error
        : ratio > 0.85
            ? AppColors.primary
            : AppColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(categoryIcon(category.name),
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    index != null
                        ? '${index!}. ${category.name} (${category.allocationPercent}%)'
                        : category.name,
                    style: AppTypography.titleSm,
                  ),
                ),
                if (locked)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Khoá an toàn',
                        style: AppTypography.labelSm
                            .copyWith(color: AppColors.error)),
                  )
                else
                  Text('${category.allocationPercent}%',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.outline)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio == 0 ? 0.02 : ratio,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Đã chi: ${formatCurrency(category.spent)} đ · Định mức: ${formatCurrency(category.limitAmount)} đ',
              style:
                  AppTypography.labelSm.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
