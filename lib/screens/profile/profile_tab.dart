import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../widgets/layout/home_tab_header.dart';
import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';

/// Tab "Người dùng" — hồ sơ cá nhân, gia đình đang tham gia, tài khoản &
/// bảo mật, đăng xuất. Thiết kế theo `finnest_tab_ng_i_d_ng`.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sẽ có ở bản cập nhật tiếp theo.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final family = context.read<FamilyProvider>();
    final transactions = context.read<TransactionProvider>();
    final notifications = context.read<NotificationProvider>();
    final user = context.read<UserProvider>();
    await context.read<AuthProvider>().logout();
    family.clear();
    transactions.clear();
    notifications.clear();
    user.clear();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<FamilyProvider>().families;
    final user = context.watch<UserProvider>().user;
    final displayName = user?.name.trim() ?? '...';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeTabHeader(
              title: 'Người dùng',
              subtitle: 'Bạn và những tổ ấm của mình',
              artwork: HomeTabArtwork.profile,
              icon: Icons.groups_outlined),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: HomeTabColors.peachTint,
                        child: Text(
                            displayName.isEmpty
                                ? '?'
                                : displayName
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .last[0]
                                    .toUpperCase(),
                            style: AppTypography.headlineLgMobile
                                .copyWith(color: HomeTabColors.coral)),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: HomeTabColors.sage,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () =>
                                _showComingSoon(context, 'Đổi ảnh đại diện'),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.camera_alt,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(displayName, style: AppTypography.titleSm),
                        Text('Thành viên FinNest', style: AppTypography.bodySm),
                        const SizedBox(height: 5),
                        _InfoRow(
                          icon: Icons.smartphone,
                          label: 'Số điện thoại',
                          value: (user?.phone.isNotEmpty ?? false)
                              ? user!.phone
                              : 'Chưa cập nhật',
                        ),
                        const SizedBox(height: 3),
                        _InfoRow(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            value: user?.email ?? '...'),
                      ])),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    label: const Text('Chỉnh sửa thông tin cá nhân'),
                    icon: const Icon(Icons.edit_outlined),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HomeTabColors.sage,
                      side: const BorderSide(color: HomeTabColors.sage),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.editProfile),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Gia đình đang tham gia (${families.length})',
              style: AppTypography.headlineSm),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                for (var i = 0; i < families.length; i++) ...[
                  Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: HomeTabColors.neutral,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.home_outlined,
                              color: HomeTabColors.sage),
                        ),
                        title: Text(families[i].name,
                            style: AppTypography.titleSm),
                        subtitle: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(families[i].code,
                                style: AppTypography.labelSm),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: HomeTabColors.sageTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                child: Text(families[i].myRole.label,
                                    style: AppTypography.labelSm
                                        .copyWith(color: HomeTabColors.sage)),
                              ),
                            ),
                            Text('${families[i].memberCount} thành viên',
                                style: AppTypography.bodySm),
                          ],
                        ),
                        trailing:
                            Icon(Icons.chevron_right, color: AppColors.outline),
                        onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.familyDetail,
                            arguments: families[i].familyId),
                      )),
                  if (i != families.length - 1)
                    Divider(height: 1, color: AppColors.surfaceContainer),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Tài khoản & Bảo mật', style: AppTypography.headlineSm),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Cấu hình danh mục tài chính',
                  subtitle: 'Tùy chỉnh 6 hũ chi tiêu và ngân sách',
                  onTap: families.isEmpty
                      ? () {}
                      : () => Navigator.of(context).pushNamed(
                          AppRoutes.familyDetail,
                          arguments: families.first.familyId),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.diversity_3,
                  title: 'Cấu hình gia đình',
                  subtitle: 'Quản lý thành viên và quyền hạn tổ ấm',
                  onTap: families.isEmpty
                      ? () {}
                      : () => Navigator.of(context).pushNamed(
                          AppRoutes.familyDetail,
                          arguments: families.first.familyId),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.lock_reset,
                  title: 'Thay đổi mật khẩu',
                  subtitle: 'Cập nhật mật khẩu bảo vệ tài khoản',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.support_agent,
                  title: 'Gửi thông tin cần hỗ trợ',
                  subtitle: 'Liên hệ và gửi yêu cầu trợ giúp',
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.supportFeedback),
                ),
                const Divider(height: 1),
                _MenuTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất tài khoản',
                  subtitle: 'Kết thúc phiên đăng nhập',
                  color: HomeTabColors.coral,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('Bảo mật dữ liệu gia đình tiêu chuẩn AES-256',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.outline)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('FinNest · Phiên bản 2.4.0',
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      hint: subtitle,
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          dense: true,
          leading:
              Icon(icon, color: color ?? AppColors.onSurfaceVariant, size: 20),
          title:
              Text(title, style: AppTypography.labelMd.copyWith(color: color)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.outline),
        const SizedBox(width: 5),
        Expanded(child: Text(value, style: AppTypography.bodySm)),
      ]),
    );
  }
}
