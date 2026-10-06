import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';
import '../../widgets/family/category_progress_tile.dart';
import 'threshold_config_screen.dart';

/// Chi tiết 1 `Family`: thành viên (`Relationship`), danh mục tài chính
/// (`FinancialCategory`) và giao dịch gần đây. Thiết kế theo
/// `chi_ti_t_t_m_finnest`. Nhận `familyId` qua `RouteSettings.arguments`.
class FamilyDetailScreen extends StatelessWidget {
  const FamilyDetailScreen({super.key, required this.familyId});

  final int familyId;

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sẽ có ở bản cập nhật tiếp theo.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final family = context.watch<FamilyProvider>().detail(familyId);
    final transactions =
        context.watch<TransactionProvider>().transactions.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Chi tiết gia đình'),
        actions: [
          IconButton(
            onPressed: () => _showComingSoon(context, 'Cài đặt gia đình'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pastelBlush.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Bạn là ${family.myRole.label.toLowerCase()}',
                      style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(height: 8),
                Text(family.name, style: AppTypography.headlineLgMobile),
                const SizedBox(height: 2),
                Text(family.code,
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                const SizedBox(height: 12),
                Text('TỔNG QUỸ CHUNG KHẢ DỤNG',
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                Row(
                  children: [
                    Text('${formatCurrency(family.totalBudget)} đ',
                        style: AppTypography.brandTitle),
                    const SizedBox(width: 8),
                    if (family.budgetGrowthPercent > 0)
                      Text('+${family.budgetGrowthPercent}%',
                          style: AppTypography.labelMd.copyWith(color: AppColors.secondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    '${family.members.length} thành viên  ·  ${family.foundedLabel}',
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_circle,
                        label: 'Thêm giao dịch',
                        filled: true,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.transactionForm),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.account_tree_outlined,
                        label: 'Thêm danh mục',
                        onTap: () => _showComingSoon(context, 'Thêm danh mục'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_alt,
                        label: 'Mời thêm',
                        onTap: () => _showComingSoon(context, 'Mời thêm thành viên'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            icon: Icons.diversity_3,
            title: 'Thành viên',
            child: Column(
              children: [
                for (final member in family.members)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.pastelLavender,
                          child: Text(member.initials,
                              style: AppTypography.labelMd
                                  .copyWith(color: AppColors.onSurface)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(member.name, style: AppTypography.bodyMd)),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(member.role.label,
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            icon: Icons.pie_chart_outline,
            title: 'Danh mục tài chính',
            child: Column(
              children: [
                for (var i = 0; i < family.categories.length; i++)
                  CategoryProgressTile(
                    category: family.categories[i],
                    index: i + 1,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.thresholdConfig,
                      arguments: ThresholdConfigArgs(
                        familyName: family.name,
                        myRole: family.myRole,
                        categoryId: family.categories[i].financialCategoryId,
                        categoryName: family.categories[i].name,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            icon: Icons.receipt_long_outlined,
            title: 'Giao dịch gia đình',
            child: Column(
              children: [
                for (final t in transactions) _TransactionRow(transaction: t),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
                    child: Text('Xem toàn bộ giao dịch tháng này →',
                        style:
                            AppTypography.labelMd.copyWith(color: AppColors.primary)),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap, this.filled = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: filled ? Colors.white : AppColors.primary),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm
                    .copyWith(color: filled ? Colors.white : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastelBlush.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.titleSm),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(transaction.content,
                style: AppTypography.bodySm, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${isExpense ? '-' : '+'}${formatCurrency(transaction.amount)} đ',
            style: AppTypography.labelMd.copyWith(
                color: isExpense ? AppColors.primary : AppColors.secondary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: transaction.status == TransactionStatus.approve
                  ? AppColors.secondaryContainer
                  : AppColors.pastelBlush,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(transaction.status.label,
                style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
