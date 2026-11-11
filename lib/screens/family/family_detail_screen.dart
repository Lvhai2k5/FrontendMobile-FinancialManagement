import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';
import '../../widgets/layout/home_tab_header.dart';
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
            tooltip: 'Làm mới',
            onPressed: provider.loading
                ? null
                : () async {
                    final transactionProvider =
                        context.read<TransactionProvider>();
                    await Future.wait([
                      provider.load(),
                      transactionProvider.load(),
                    ]);
                    if (!context.mounted) return;
                    final error = provider.errorMessage;
                    showSnack(context, error ?? 'Đã làm mới dữ liệu.',
                        error: error != null);
                  },
            icon: provider.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.refresh),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(family.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.headlineSm),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _HeaderChip(
                                  icon: Icons.verified_user_outlined,
                                  label:
                                      'Bạn là ${family.myRole.label.toLowerCase()}'),
                              const SizedBox(width: 8),
                              _HeaderChip(
                                  icon: Icons.group_outlined,
                                  label: '${family.members.length} thành viên'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(color: HomeTabColors.border, width: 1.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: family.canRead
                      ? Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined,
                                color: AppColors.primary, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                    '${formatCurrency(family.totalBudget)} đ',
                                    style: AppTypography.brandTitle),
                              ),
                            ),
                            if (family.budgetGrowthPercent > 0) ...[
                              const SizedBox(width: 8),
                              Text('+${family.budgetGrowthPercent}%',
                                  style: AppTypography.labelMd
                                      .copyWith(color: AppColors.secondary)),
                            ],
                          ],
                        )
                      : Text('Bạn chưa có quyền Xem dữ liệu tài chính.',
                          style: AppTypography.bodySm),
                ),
                if (family.foundedLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(family.foundedLabel,
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.outline)),
                ],
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
                            tint: HomeTabColors.sageTint,
                            accent: HomeTabColors.sage,
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
            title: 'Thành viên (${family.members.length})',
            child: Column(
              children: [
                if (family.isOwner) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _OutlineAction(
                          icon: Icons.person_add_alt,
                          label: 'Thêm thành viên',
                          tint: HomeTabColors.sageTint,
                          accent: HomeTabColors.sage,
                          onTap: () => addFamilyMember(context, familyId),
                        ),
                      ),
                      if (family.code.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _OutlineAction(
                            icon: Icons.link,
                            label: 'Mã mời',
                            tint: HomeTabColors.wheatTint,
                            accent: HomeTabColors.amber,
                            onTap: () => showInviteCode(context, family.code),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                for (final member in family.members)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border:
                          Border.all(color: HomeTabColors.border, width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.pastelLavender,
                          child: Text(member.initials,
                              style: AppTypography.labelMd
                                  .copyWith(color: AppColors.onSurface)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(member.name,
                                style: AppTypography.titleSm)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: member.role == MemberRole.owner
                                ? HomeTabColors.sageTint
                                : HomeTabColors.neutral,
                            border: Border.all(
                                color: member.role == MemberRole.owner
                                    ? HomeTabColors.sage.withValues(alpha: 0.4)
                                    : HomeTabColors.border),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(member.role.label,
                              style: AppTypography.labelSm.copyWith(
                                  color: member.role == MemberRole.owner
                                      ? HomeTabColors.sage
                                      : AppColors.onSurfaceVariant)),
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
                  for (final (index, category) in family.categories.indexed)
                    CategoryProgressTile(
                      category: category,
                      index: index + 1,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.thresholdConfig,
                        arguments: ThresholdConfigArgs(
                          familyName: family.name,
                          myRole: family.myRole,
                          categoryId: category.financialCategoryId,
                          categoryName: category.name,
                        ),
                      ),
                      trailing: family.isOwner ||
                              (family.canApprove &&
                                  category.status == CategoryStatus.locked)
                          ? _CategoryLockButton(
                              category: CategoryAction(
                                category.financialCategoryId,
                                category.name,
                                category.status == CategoryStatus.locked,
                              ),
                            )
                          : null,
                    ),
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label,
                style:
                    AppTypography.labelSm.copyWith(color: AppColors.primary)),
          ],
        ),
      );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.filled = false,
      this.tint,
      this.accent});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final Color? tint;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary
              : (tint ?? AppColors.surfaceContainerLowest),
          border: Border.all(
              color: filled
                  ? AppColors.primaryDark
                  : (accent ?? AppColors.primary).withValues(alpha: 0.6),
              width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 18,
                color: filled ? Colors.white : (accent ?? AppColors.primary)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.labelMd.copyWith(
                    color: filled
                        ? Colors.white
                        : (accent ?? AppColors.onSurfaceVariant))),
          ],
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction(
      {required this.icon,
      required this.label,
      required this.tint,
      required this.accent,
      required this.onTap});

  final IconData icon;
  final String label;
  final Color tint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            color: tint,
            border:
                Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(color: accent)),
              ),
            ],
          ),
        ),
      );
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
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.transactionDetail,
          arguments: transaction.transactionId),
      child: Padding(
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
                color: transaction.status.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(transaction.status.label,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
