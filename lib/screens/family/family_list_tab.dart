import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../widgets/layout/home_tab_header.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';
import 'family_actions.dart';

/// Danh sách cuộn theo gia đình, dùng cùng thang chữ với Tổng quan.
class FamilyListTab extends StatelessWidget {
  const FamilyListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final families = provider.families;
    final owners = families.where((f) => f.myRole == MemberRole.owner).length;
    return RefreshIndicator(
      onRefresh: provider.load,
      child: CustomScrollView(
        key: const PageStorageKey('family-list-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const HomeTabHeader(
                        title: 'Gia đình',
                        icon: Icons.groups_outlined),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: HomeTabColors.neutral,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.diversity_3_outlined,
                                      size: 22, color: HomeTabColors.sage)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        'Đang tham gia ${families.length} gia đình',
                                        style: AppTypography.titleSm),
                                    const SizedBox(height: 8),
                                    Wrap(spacing: 8, runSpacing: 6, children: [
                                      _RoleLabel(
                                          label: 'Chủ hộ $owners', owner: true),
                                      _RoleLabel(
                                          label:
                                              'Thành viên ${families.length - owners}'),
                                    ]),
                                  ])),
                            ])),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 330 ||
                          MediaQuery.textScalerOf(context).scale(14) > 17;
                      final width = stacked
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(spacing: 12, runSpacing: 10, children: [
                        SizedBox(
                            width: width,
                            child: _ActionCard(
                                icon: Icons.vpn_key_outlined,
                                title: 'Nhập mã mời',
                                subtitle: 'Tham gia tổ ấm',
                                onTap: () => promptJoinFamily(context))),
                        SizedBox(
                            width: width,
                            child: _ActionCard(
                                icon: Icons.add_home_outlined,
                                title: 'Tạo gia đình mới',
                                subtitle: 'Bắt đầu quỹ chung',
                                highlighted: true,
                                onTap: () => promptCreateFamily(context))),
                      ]);
                    }),
                    const SizedBox(height: 20),
                    Text('Tổ ấm của bạn', style: AppTypography.headlineSm),
                    const SizedBox(height: 12),
                    if (provider.loading)
                      const Padding(
                          padding: EdgeInsets.all(12),
                          child: LinearProgressIndicator()),
                    if (provider.errorMessage != null)
                      TextButton.icon(
                          onPressed: provider.load,
                          icon: const Icon(Icons.refresh),
                          label:
                              const Text('Chưa tải được danh sách. Thử lại')),
                    if (families.isEmpty &&
                        !provider.loading &&
                        provider.errorMessage == null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                              'Bạn chưa tham gia gia đình nào.\nHãy tạo gia đình mới hoặc nhập mã mời.',
                              style: AppTypography.bodyMd
                                  .copyWith(color: AppColors.outline))),
                  ]))),
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                  itemCount: families.length,
                  itemBuilder: (context, index) {
                    final family = families[index];
                    return _FamilyCard(
                        key: ValueKey('family-card-${family.familyId}'),
                        family: family,
                        onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.familyDetail,
                            arguments: family.familyId));
                  })),
        ],
      ),
    );
  }
}

class _RoleLabel extends StatelessWidget {
  const _RoleLabel({required this.label, this.owner = false});
  final String label;
  final bool owner;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: owner ? HomeTabColors.sageTint : HomeTabColors.neutral,
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: AppTypography.labelSm
              .copyWith(color: AppColors.onSurfaceVariant)));
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.highlighted = false});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;
  @override
  Widget build(BuildContext context) => Material(
      color: highlighted ? AppColors.surfaceContainerLow : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: HomeTabColors.sage, size: 22),
                    const SizedBox(height: 6),
                    Text(title, style: AppTypography.labelMd),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.outline)),
                  ]))));
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({super.key, required this.family, required this.onTap});
  final FamilySummaryModel family;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: HomeTabColors.neutral,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.home_outlined,
                                      color: HomeTabColors.sage, size: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(family.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.titleSm),
                                    const SizedBox(height: 4),
                                    Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          _RoleLabel(
                                              label: family.myRole.label,
                                              owner: family.myRole ==
                                                  MemberRole.owner),
                                          Text(family.code,
                                              style: AppTypography.bodySm
                                                  .copyWith(
                                                      color:
                                                          AppColors.outline)),
                                        ]),
                                  ])),
                              const Icon(Icons.chevron_right,
                                  size: 20, color: AppColors.outline),
                            ]),
                        const SizedBox(height: 12),
                        if (!family.canRead)
                          Text('Chưa có quyền Xem', style: AppTypography.bodySm)
                        else
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: HomeTabColors.neutral,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tổng quỹ chung',
                                        style: AppTypography.bodySm.copyWith(
                                            color: AppColors.onSurface)),
                                    const SizedBox(height: 4),
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                      final amount = Text(
                                          '${formatCurrency(family.totalBudget)} đ',
                                          style: AppTypography.amountMd.copyWith(
                                              color: AppColors.onSurface));
                                      final jars = Text(
                                          '${family.categoryCount} danh mục tài chính',
                                          style: AppTypography.bodySm.copyWith(
                                              color: AppColors.onSurface));
                                      if (constraints.maxWidth < 300 ||
                                          MediaQuery.textScalerOf(context)
                                                  .scale(14) >
                                              17) {
                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              amount,
                                              const SizedBox(height: 6),
                                              jars
                                            ]);
                                      }
                                      return Row(children: [
                                        Expanded(child: amount),
                                        const SizedBox(width: 10),
                                        jars
                                      ]);
                                    }),
                                  ])),
                        const SizedBox(height: 10),
                        Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (family.members.isNotEmpty)
                                _AvatarStack(
                                    members: family.members,
                                    extra: family.memberCount > 3
                                        ? family.memberCount - 3
                                        : 0),
                              Text('${family.memberCount} thành viên',
                                  style: AppTypography.bodySm
                                      .copyWith(color: AppColors.outline)),
                            ]),
                        const SizedBox(height: 8),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text('Xem chi tiết gia đình →',
                                style: AppTypography.labelMd
                                    .copyWith(color: HomeTabColors.sage))),
                      ])))));
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.members, required this.extra});

  final List<FamilyMemberModel> members;
  final int extra;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(3).toList();
    final count = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      width: count == 0 ? 0 : (count - 1) * 20.0 + 28,
      height: 28,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceContainerLowest,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: HomeTabColors.sageTint,
                  child: Text(shown[i].initials,
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.onSurface)),
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * 20.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceContainerLowest,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text('+$extra',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
