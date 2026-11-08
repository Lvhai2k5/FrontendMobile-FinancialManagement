import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/registration_validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/password_strength_meter.dart';
import '../../widgets/common/terms_sheet.dart';
import '../otp/otp_verify_screen.dart';

/// Kiểm tra từng trường trước khi gọi API đăng ký và chuyển sang OTP.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _confirmKey = GlobalKey<FormFieldState<String>>();
  bool _submitted = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
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
      setState(
          () => _strength = evaluatePasswordStrength(_passwordController.text));
      if (_confirmController.text.isNotEmpty) {
        _confirmKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
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

  Future<void> _handleSubmit() async {
    if (context.read<AuthProvider>().loading) return;
    setState(() => _submitted = true);
    final valid = _formKey.currentState!.validate();
    if (!valid || !_agreeTerms) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = RegistrationValidators.normalizePhone(_phoneController.text);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final error = await context.read<AuthProvider>().register(
          name: name,
          username: username,
          email: email,
          phone: phone,
          password: password,
        );
    if (!mounted) return;
    if (error != null) {
      _showError(error);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.otpVerify,
      arguments: OtpVerifyArgs(email: email, purpose: OtpPurpose.register),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
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
                'Tạo tài khoản mới',
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Họ và tên',
                        validator: RegistrationValidators.name,
                        controller: _nameController,
                        hintText: 'Nhập họ và tên',
                        prefixIcon: Icons.person_outline,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Gmail',
                        validator: RegistrationValidators.gmail,
                        controller: _emailController,
                        hintText: 'ten@gmail.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Số điện thoại',
                        validator: RegistrationValidators.phone,
                        controller: _phoneController,
                        hintText: '0912 345 678',
                        prefixIcon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Tên tài khoản',
                        validator: RegistrationValidators.username,
                        controller: _usernameController,
                        hintText: 'Nhập tên tài khoản',
                        prefixIcon: Icons.account_circle_outlined,
                        autofillHints: const [AutofillHints.newUsername],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Mật khẩu',
                        validator: RegistrationValidators.password,
                        controller: _passwordController,
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 8),
                      PasswordStrengthMeter(strength: _strength),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Xác nhận mật khẩu',
                        fieldKey: _confirmKey,
                        validator: (value) =>
                            RegistrationValidators.confirmPassword(
                                value, _passwordController.text),
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
                      if (_submitted && !_agreeTerms)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                              'Vui lòng đồng ý Điều khoản dịch vụ & Chính sách.',
                              style: AppTypography.bodySm
                                  .copyWith(color: AppColors.error)),
                        ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: loading
                            ? 'Đang tạo tài khoản...'
                            : 'Tạo tài khoản ngay',
                        trailingIcon: loading ? null : Icons.arrow_forward,
                        backgroundColor: AppColors.primaryContainer,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 4,
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
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
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
    return Semantics(
      key: const ValueKey('register-consent'),
      checked: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (value) {
            onChanged(false);
            return;
          }
          final agreed = await showTermsSheet(context);
          if (agreed == true) onChanged(true);
        },
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
                            fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' & '),
                    TextSpan(
                        text: 'Chính sách',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' của FinNest'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
