import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../utils/format_currency.dart';
import '../layout/home_tab_header.dart';

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

/// % đã dùng = đã chi / định mức của chính danh mục (không phải tỷ trọng
/// trong tổng quỹ). Dưới 10% giữ 1 chữ số thập phân để không hiện "0%".
String _usedPercentLabel(FinancialCategoryModel c) {
  if (c.limitAmount <= 0) return '0%';
  final pct = c.spent / c.limitAmount * 100;
  if (pct >= 10 || pct == 0) return '${pct.round()}%';
  final text = pct.toStringAsFixed(1);
  if (text.endsWith('.0')) return '${text.substring(0, text.length - 2)}%';
  return '${text.replaceAll('.', ',')}%';
}

/// Một danh mục với thanh tiến độ chi/định mức — dùng chung ở tab
/// Tổng quan và màn Chi tiết gia đình. Widget thuần túy: chỉ nhận
/// [category] và callback [onTap] tuỳ nơi gọi (mở cấu hình hạn mức hay
/// không).
class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    super.key,
    required this.category,
    this.onTap,
    this.index,
    this.trailing,
  });

  final FinancialCategoryModel category;
  final VoidCallback? onTap;
  final int? index;
  final Widget? trailing;

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
          border: Border.all(color: HomeTabColors.border, width: 1.2),
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
                        ? '${index!}. ${category.name}'
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
                  ),
                if (trailing case final action?) action,
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
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Đã dùng ${_usedPercentLabel(category)}',
                    style: AppTypography.labelMd.copyWith(color: barColor)),
                const Spacer(),
                Flexible(
                  child: Text(
                    '${formatCurrency(category.spent)} / ${formatCurrency(category.limitAmount)} đ',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
