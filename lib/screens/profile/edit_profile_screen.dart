import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../utils/registration_validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Chỉnh sửa thông tin cá nhân của tài khoản đang đăng nhập.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _savedEmail;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn thông tin thật của tài khoản đang đăng nhập.
    final user = context.read<UserProvider>().user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _savedEmail = user?.email.trim() ?? '';
    _emailController.text = _savedEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final email = _emailController.text.trim();
    final error = await context.read<UserProvider>().updateProfile(
          name: _nameController.text.trim(),
          phone: RegistrationValidators.normalizePhone(_phoneController.text),
          email: email,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) _savedEmail = email;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Đã lưu thay đổi.'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error == null ? AppColors.secondary : AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        leading: widget.onClose == null
            ? null
            : BackButton(onPressed: widget.onClose),
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.pastelBlush,
                    child: Text(
                        _nameController.text.trim().isEmpty
                            ? '?'
                            : _nameController.text
                                .trim()
                                .split(RegExp(r'\s+'))
                                .last[0]
                                .toUpperCase(),
                        style: AppTypography.pageTitle
                            .copyWith(color: AppColors.primary)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Thông tin cơ bản', style: AppTypography.titleSm),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      compact: true,
                      label: 'Họ và tên (*)',
                      controller: _nameController,
                      hintText: 'Nhập họ và tên',
                      prefixIcon: Icons.person_outline,
                      validator: RegistrationValidators.name,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      compact: true,
                      label: 'Số điện thoại (*)',
                      controller: _phoneController,
                      hintText: '0912 345 678',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: RegistrationValidators.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      compact: true,
                      label: 'Địa chỉ Email (*)',
                      controller: _emailController,
                      hintText: 'ten@gmail.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          _savedEmail.isNotEmpty && value?.trim() == _savedEmail
                              ? null
                              : RegistrationValidators.gmail(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: _saving ? 'Đang lưu...' : 'Lưu thay đổi',
              leadingIcon: _saving ? null : Icons.check,
              onPressed: _saving ? () {} : _save,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Hủy bỏ',
              variant: AppButtonVariant.secondary,
              onPressed:
                  widget.onClose ?? () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
