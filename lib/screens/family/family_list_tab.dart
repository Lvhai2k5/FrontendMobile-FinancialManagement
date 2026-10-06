import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';

/// Tab "Gia đình" — danh sách các `Family` mà Person hiện tại tham gia, mỗi
/// dòng dẫn sang màn Chi tiết gia đình. Thiết kế theo `finnest_tab_gia_nh`.
class FamilyListTab extends StatelessWidget {
  const FamilyListTab({super.key});

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
    final families = context.watch<FamilyProvider>().families;
    final ownerCount =
        families.where((f) => f.myRole == MemberRole.owner).length;
    final memberCount = families.length - ownerCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlush,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.diversity_3,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bạn đang tham gia ${families.length} gia đình',
                              style: AppTypography.titleSm),
                          Text('Đồng bộ ngân sách và kết nối tài chính',
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.outline)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _RoleStat(count: ownerCount, label: 'Vai trò\nChủ hộ')),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            _RoleStat(count: memberCount, label: 'Vai trò\nThành viên')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.vpn_key_outlined,
                  title: 'Nhập mã mời',
                  subtitle: 'Gia nhập gia đình',
                  onTap: () => _showComingSoon(context, 'Nhập mã mời'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.add_home_outlined,
                  title: 'Tạo gia đình mới',
                  subtitle: 'Bắt đầu quỹ chung',
                  onTap: () => _showComingSoon(context, 'Tạo gia đình mới'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Danh sách gia đình', style: AppTypography.headlineSm),
              Text('${families.length} gia đình',
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 12),
          for (final family in families)
            _FamilyCard(
              family: family,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.familyDetail,
                arguments: family.familyId,
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleStat extends StatelessWidget {
  const _RoleStat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('$count', style: AppTypography.headlineSm),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.titleSm),
            Text(subtitle,
                style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({required this.family, required this.onTap});

  final FamilySummaryModel family;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final extra = family.memberCount > 3 ? family.memberCount - 3 : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(family.name,
                                style: AppTypography.titleSm,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: family.myRole == MemberRole.owner
                                  ? AppColors.secondaryContainer
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(family.myRole.label,
                                style: AppTypography.labelSm
                                    .copyWith(color: AppColors.onSurfaceVariant)),
                          ),
                        ],
                      ),
                      Text('${family.code} · ${family.memberCount} thành viên',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.outline)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng quỹ chung',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.outline)),
                        Text('${formatCurrency(family.totalBudget)} đ',
                            style: AppTypography.titleSm),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Danh mục',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.outline)),
                      Text('${family.categoryCount} danh mục',
                          style: AppTypography.titleSm),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AvatarStack(members: family.members, extra: extra),
                Row(
                  children: [
                    Text('Vào chi tiết gia đình',
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.members, required this.extra});

  final List<FamilyMemberModel> members;
  final int extra;

  @override
  Widget build(BuildContext context) {
    final shown = members.take(3).toList();
    return SizedBox(
      width: shown.length * 22.0 + (extra > 0 ? 24 : 0),
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
                  backgroundColor: AppColors.pastelLavender,
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
