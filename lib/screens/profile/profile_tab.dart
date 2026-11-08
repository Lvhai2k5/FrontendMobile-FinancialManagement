import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';

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
    final displayName = user?.name ?? '...';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.pastelLavender,
                      child: Text(
                          displayName.isEmpty
                              ? '?'
                              : displayName
                                  .trim()
                                  .split(RegExp(r'\s+'))
                                  .last[0]
                                  .toUpperCase(),
                          style: AppTypography.headlineLgMobile
                              .copyWith(color: AppColors.onSurface)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: AppColors.primary,
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
                const SizedBox(height: 12),
                Text(displayName, style: AppTypography.headlineSm),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                          icon: Icons.smartphone,
                          label: 'Số điện thoại',
                          value: (user?.phone.isNotEmpty ?? false)
                              ? user!.phone
                              : 'Chưa cập nhật'),
                      const SizedBox(height: 8),
                      _InfoRow(
                          icon: Icons.mail_outline,
                          label: 'Email',
                          value: user?.email ?? '...'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Chỉnh sửa thông tin cá nhân',
                  leadingIcon: Icons.edit_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.editProfile),
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
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlush,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.diversity_3,
                          color: AppColors.primary),
                    ),
                    title: Text(families[i].name, style: AppTypography.titleSm),
                    subtitle: Text(
                        'Vai trò: ${families[i].myRole.label} · ${families[i].memberCount} thành viên',
                        style: AppTypography.labelSm
                            .copyWith(color: AppColors.outline)),
                    trailing:
                        Icon(Icons.chevron_right, color: AppColors.outline),
                    onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.familyDetail,
                        arguments: families[i].familyId),
                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Đăng xuất tài khoản',
            leadingIcon: Icons.logout,
            backgroundColor: AppColors.pastelBlush,
            onPressed: () => _handleLogout(context),
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
                    Text('Bảo mật dữ liệu gia đình tiêu chuẩn AES-256',
                        style: AppTypography.labelSm
                            .copyWith(color: AppColors.outline)),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.pastelBlush,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTypography.titleSm),
      subtitle: Text(subtitle,
          style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
      trailing: Icon(Icons.chevron_right, color: AppColors.outline),
      onTap: onTap,
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
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(label,
            style: AppTypography.bodySm
                .copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: AppTypography.titleSm),
      ],
    );
  }
}
