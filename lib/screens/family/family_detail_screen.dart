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
import 'family_actions.dart';
import 'family_management_actions.dart';
import 'threshold_config_screen.dart';

/// Chi tiết 1 `Family`: thành viên (`Relationship`), danh mục tài chính
/// (`FinancialCategory`) và giao dịch gần đây. Thiết kế theo
/// `chi_ti_t_t_m_finnest`. Nhận `familyId` qua `RouteSettings.arguments`.
class FamilyDetailScreen extends StatelessWidget {
  const FamilyDetailScreen({super.key, required this.familyId});

  final int familyId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final family = provider.detail(familyId);
    final transactions = context
        .watch<TransactionProvider>()
        .forFamily(familyId)
        .take(5)
        .toList();

    if (family == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Chi tiết gia đình'),
        ),
        body: Center(
            child: provider.loading
                ? const CircularProgressIndicator()
                : const Text('Bạn không còn quyền truy cập tổ ấm này.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Chi tiết gia đình'),
        actions: [
          IconButton(
            tooltip: 'Tải lại gia đình',
            onPressed: provider.loading
                ? null
                : () => Future.wait([
                      provider.load(),
                      context.read<TransactionProvider>().load(),
                    ]),
            icon: const Icon(Icons.refresh),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Bạn là ${family.myRole.label.toLowerCase()}',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.primary)),
                ),
                const SizedBox(height: 8),
                Text(family.name, style: AppTypography.headlineLgMobile),
                const SizedBox(height: 2),
                const SizedBox(height: 12),
                if (family.canRead) ...[
                  Text('TỔNG QUỸ CHUNG KHẢ DỤNG',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.outline)),
                  Row(
                    children: [
                      Text('${formatCurrency(family.totalBudget)} đ',
                          style: AppTypography.brandTitle),
                      const SizedBox(width: 8),
                      if (family.budgetGrowthPercent > 0)
                        Text('+${family.budgetGrowthPercent}%',
                            style: AppTypography.labelMd
                                .copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ] else
                  Text('Bạn chưa có quyền Xem dữ liệu tài chính.',
                      style: AppTypography.bodySm),
                const SizedBox(height: 4),
                Text(
                    '${family.members.length} thành viên${family.foundedLabel.isEmpty ? '' : '  ·  ${family.foundedLabel}'}',
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline)),
                const SizedBox(height: 14),
                if (family.canWrite || family.isOwner)
                  Row(
                    children: [
                      if (family.canWrite)
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_circle,
                            label: 'Thêm giao dịch',
                            filled: true,
                            onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.transactionForm,
                                arguments: familyId),
                          ),
                        ),
                      if (family.canWrite && family.isOwner)
                        const SizedBox(width: 8),
                      if (family.isOwner)
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.account_tree_outlined,
                            label: 'Thêm danh mục',
                            onTap: () =>
                                promptCreateCategory(context, familyId),
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
                if (family.isOwner)
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_alt),
                        onPressed: () => addFamilyMember(context, familyId),
                        label: const Text('Thêm thành viên'),
                      ),
                      if (family.code.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.link),
                          onPressed: () => showInviteCode(context, family.code),
                          label: const Text('Mã mời'),
                        ),
                    ],
                  ),
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
                            child:
                                Text(member.name, style: AppTypography.bodyMd)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(member.role.label,
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                        if (family.isOwner && member.role != MemberRole.owner)
                          MemberManagementMenu(
                              familyId: familyId, member: member),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (family.canRead)
            _SectionCard(
              icon: Icons.pie_chart_outline,
              title: 'Danh mục tài chính',
              child: Column(
                children: [
                  for (var i = 0; i < family.categories.length; i++)
                    Row(children: [
                      Expanded(
                          child: CategoryProgressTile(
                        category: family.categories[i],
                        index: i + 1,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.thresholdConfig,
                          arguments: ThresholdConfigArgs(
                            familyName: family.name,
                            myRole: family.myRole,
                            categoryId:
                                family.categories[i].financialCategoryId,
                            categoryName: family.categories[i].name,
                          ),
                        ),
                      )),
                      if (family.isOwner ||
                          (family.canApprove &&
                              family.categories[i].status ==
                                  CategoryStatus.locked))
                        _CategoryLockButton(
                            category: CategoryAction(
                          family.categories[i].financialCategoryId,
                          family.categories[i].name,
                          family.categories[i].status == CategoryStatus.locked,
                        )),
                    ]),
                ],
              ),
            ),
          if (!family.canRead && family.canApprove)
            _SectionCard(
              icon: Icons.lock_open_outlined,
              title: 'Mở khóa danh mục',
              child: Column(
                children: [
                  if (!family.actionCategories.any((c) => c.locked))
                    const Text('Không có danh mục đang khóa.'),
                  for (final category
                      in family.actionCategories.where((c) => c.locked))
                    ListTile(
                      title: Text(category.name),
                      trailing: _CategoryLockButton(
                          category: category, showLabel: true),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (family.canRead)
            _SectionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Giao dịch gia đình',
              child: Column(
                children: [
                  for (final t in transactions) _TransactionRow(transaction: t),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.familyTransactions,
                          arguments: familyId),
                      child: Text('Xem toàn bộ giao dịch tháng này →',
                          style: AppTypography.labelMd
                              .copyWith(color: AppColors.primary)),
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

class _CategoryLockButton extends StatelessWidget {
  const _CategoryLockButton({required this.category, this.showLabel = false});

  final CategoryAction category;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return Tooltip(
        message: 'Mở khóa ${category.name}',
        child: TextButton.icon(
          icon: const Icon(Icons.lock_open_outlined),
          onPressed: () => changeCategoryLock(context, category),
          label: const Text('Mở khóa'),
        ),
      );
    }
    return IconButton(
      tooltip: category.locked
          ? 'Mở khóa ${category.name}'
          : 'Khóa ${category.name}',
      icon:
          Icon(category.locked ? Icons.lock_open_outlined : Icons.lock_outline),
      onPressed: () => changeCategoryLock(context, category),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.filled = false});

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
            Icon(icon,
                size: 18, color: filled ? Colors.white : AppColors.primary),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                    color: filled ? Colors.white : AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

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
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
