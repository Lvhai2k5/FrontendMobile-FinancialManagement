import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
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
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<FamilyProvider>().families;

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
                      child: Text('M',
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
                          onTap: () => _showComingSoon(context, 'Đổi ảnh đại diện'),
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
                Text('Nguyễn Văn Minh', style: AppTypography.headlineSm),
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
                          value: '0912 345 678'),
                      const SizedBox(height: 8),
                      _InfoRow(
                          icon: Icons.mail_outline,
                          label: 'Email',
                          value: 'minh.nguyen@email.com'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Chỉnh sửa thông tin cá nhân',
                  leadingIcon: Icons.edit_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      _showComingSoon(context, 'Chỉnh sửa thông tin cá nhân'),
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
                      child: const Icon(Icons.diversity_3, color: AppColors.primary),
                    ),
                    title: Text(families[i].name, style: AppTypography.titleSm),
                    subtitle: Text(
                        'Vai trò: ${families[i].myRole.label} · ${families[i].memberCount} thành viên',
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                    trailing: Icon(Icons.chevron_right, color: AppColors.outline),
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
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_reset, color: AppColors.primary),
              ),
              title: Text('Thay đổi mật khẩu', style: AppTypography.titleSm),
              subtitle: Text('Cập nhật mật khẩu bảo vệ tài khoản',
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
              trailing: Icon(Icons.chevron_right, color: AppColors.outline),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
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
                    Icon(Icons.shield_outlined, size: 14, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text('Bảo mật dữ liệu gia đình tiêu chuẩn AES-256',
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('FinNest · Phiên bản 2.4.0',
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: AppTypography.titleSm),
      ],
    );
  }
}
