import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Chỉnh sửa thông tin cá nhân — thiết kế `screen8.1`. Dữ liệu hiện là
/// dữ liệu demo cục bộ (Backend chưa có endpoint hồ sơ).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthController = TextEditingController();
  bool _receiveReport = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn thông tin thật của tài khoản đang đăng nhập.
    final user = context.read<UserProvider>().user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng nhập đủ các trường bắt buộc (*).'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
      return;
    }
    setState(() => _saving = true);
    final error = await context.read<UserProvider>().updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Đã lưu thay đổi.'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error == null ? AppColors.secondary : AppColors.error,
    ));
    if (error == null) Navigator.of(context).pop();
  }

  FamilySummaryModel? get _family =>
      context.read<FamilyProvider>().selectedFamily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: Text('Chỉnh sửa thông tin', style: AppTypography.titleSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.pastelBlush,
                    child: Text(
                        _nameController.text.trim().isEmpty
                            ? '?'
                            : _nameController.text
                                .trim()
                                .split(RegExp(r'\s+'))
                                .last[0]
                                .toUpperCase(),
                        style: AppTypography.brandTitle
                            .copyWith(color: AppColors.primary)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Hỗ trợ định dạng JPG, PNG (tối đa 5MB)',
                  style:
                      AppTypography.bodySm.copyWith(color: AppColors.outline)),
            ),
            const SizedBox(height: 16),
            Container(
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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.secondaryContainer,
                        child: const Icon(Icons.home_outlined,
                            color: AppColors.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_family?.name ?? 'Chưa có gia đình',
                                style: AppTypography.titleSm),
                            Text(
                                _family == null
                                    ? 'Hãy tạo hoặc gia nhập một tổ ấm'
                                    : 'Tổ ấm chính · ${_family!.code}',
                                style: AppTypography.bodySm
                                    .copyWith(color: AppColors.outline)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.pastelBlush,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(_family?.myRole.label ?? '—',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.primary)),
                      ),
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
                        const Icon(Icons.shield_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _family?.myRole == MemberRole.owner
                                ? 'Bạn có toàn quyền phê duyệt giao dịch và thiết lập hạn mức chi tiêu cho các hũ tài chính của tổ ấm.'
                                : 'Bạn có thể ghi giao dịch trong tổ ấm; giao dịch vượt hạn mức sẽ chờ Chủ hộ duyệt.',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Thông tin cơ bản', style: AppTypography.titleSm),
                      const Spacer(),
                      Text('Bắt buộc (*)',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Họ và tên *',
                    controller: _nameController,
                    hintText: 'Nhập họ và tên',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Số điện thoại *',
                    controller: _phoneController,
                    hintText: '0912 345 678',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Địa chỉ Email *',
                    controller: _emailController,
                    hintText: 'example@email.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _receiveReport = !_receiveReport),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: _receiveReport
                                ? AppColors.primary
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _receiveReport
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nhận thông báo biến động số dư lớn & báo cáo tổng kết tài chính tổ ấm hàng tháng qua email.',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Ngày sinh',
                    controller: _birthController,
                    hintText: 'dd/mm/yyyy',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: _saving ? 'Đang lưu...' : 'Lưu thay đổi',
              leadingIcon: _saving ? null : Icons.check,
              onPressed: _saving ? () {} : _save,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Hủy bỏ',
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
