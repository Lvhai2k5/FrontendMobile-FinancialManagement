import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/password_strength_meter.dart';
import '../otp/otp_verify_screen.dart';

/// Màn hình đăng ký. Backend chưa có endpoint `/auth/register` (không có
/// trong `TECH-AUTH.md`) nên screen chỉ validate phía client rồi điều hướng
/// sang xác thực OTP — khi Backend có API thật, thay đoạn validate-rồi-điều-
/// hướng bằng gọi `AuthProvider.register()` như `LoginScreen` đang gọi
/// `AuthProvider.login()`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập đầy đủ thông tin.');
      return;
    }
    if (password != confirm) {
      _showError('Xác nhận mật khẩu không khớp.');
      return;
    }
    if (password.length < 8) {
      _showError('Mật khẩu cần tối thiểu 8 ký tự.');
      return;
    }
    if (!_agreeTerms) {
      _showError('Vui lòng đồng ý Điều khoản dịch vụ & Chính sách.');
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.otpVerify,
      arguments: OtpVerifyArgs(email: email, purpose: OtpPurpose.register),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 16),
              Text(
                'Tạo tài khoản mới ✨',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLgMobile,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
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
                      label: 'Họ và tên',
                      controller: _nameController,
                      hintText: 'Nhập họ và tên',
                      prefixIcon: Icons.person_outline,
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      hintText: 'example@email.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Số điện thoại',
                      controller: _phoneController,
                      hintText: '0912 345 678',
                      prefixIcon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Mật khẩu',
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
                      label: 'Xác nhận mật khẩu',
                      controller: _confirmController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 16),
                    _TermsCheckbox(
                      value: _agreeTerms,
                      onChanged: (value) =>
                          setState(() => _agreeTerms = value),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Tạo tài khoản ngay',
                      trailingIcon: Icons.arrow_forward,
                      backgroundColor: AppColors.primaryContainer,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản? ',
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Đăng nhập ngay',
                              style: AppTypography.titleSm
                                  .copyWith(color: AppColors.primary)),
                          Icon(Icons.chevron_right,
                              size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Material(
            color: AppColors.surfaceContainerLow,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.jpg',
                      width: 32, height: 32, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Text('FinNest',
                    style: AppTypography.headlineSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'Tôi đồng ý với '),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' & '),
                  TextSpan(
                    text: 'Chính sách',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' của FinNest'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
