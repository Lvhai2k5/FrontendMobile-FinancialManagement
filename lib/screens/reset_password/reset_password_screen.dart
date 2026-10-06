import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/password_strength_meter.dart';

class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email});

  final String email;
}

/// Bước cuối của luồng Quên mật khẩu — đặt mật khẩu mới sau khi OTP đã xác
/// thực. Không có thiết kế Stitch riêng cho màn này (chỉ có 2 bước nhập
/// email + OTP) nên dựng theo đúng phong cách input/nút của `RegisterScreen`
/// để đồng bộ toàn app.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.args});

  final ResetPasswordArgs args;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  PasswordStrength _strength = PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() =>
          _strength = evaluatePasswordStrength(_passwordController.text));
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleSubmit() {
    final password = _passwordController.text;
    if (password.length < 8) {
      _showError('Mật khẩu cần tối thiểu 8 ký tự.');
      return;
    }
    if (password != _confirmController.text) {
      _showError('Xác nhận mật khẩu không khớp.');
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đặt lại mật khẩu thành công! Hãy đăng nhập lại.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text('Đặt lại mật khẩu 🔒', style: AppTypography.headlineLgMobile),
              const SizedBox(height: 8),
              Text(
                'Tạo mật khẩu mới cho ${widget.args.email}',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Mật khẩu mới',
                      controller: _passwordController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 8),
                    PasswordStrengthMeter(strength: _strength),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Xác nhận mật khẩu mới',
                      controller: _confirmController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Lưu mật khẩu mới',
                      trailingIcon: Icons.check,
                      backgroundColor: AppColors.primaryContainer,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
