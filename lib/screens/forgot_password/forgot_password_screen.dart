import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../otp/otp_verify_screen.dart';

/// Bước 1 của luồng Quên mật khẩu: nhập email đã đăng ký để nhận OTP. Backend
/// chưa có endpoint gửi OTP quên mật khẩu — bấm gửi sẽ chuyển thẳng sang màn
/// OTP (mã demo cố định, xem `OtpVerifyScreen`).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đúng định dạng email.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _sent = true);
    Navigator.of(context).pushNamed(
      AppRoutes.otpVerify,
      arguments:
          OtpVerifyArgs(email: email, purpose: OtpPurpose.resetPassword),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/logo.jpg',
                        width: 32, height: 32, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Text('FinNest',
                      style: AppTypography.headlineSm
                          .copyWith(color: AppColors.secondary)),
                ],
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
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.vpn_key_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('Quên mật khẩu? 🔑', style: AppTypography.headlineSm),
                    const SizedBox(height: 8),
                    Text(
                      'Nhập email đã đăng ký để nhận mã xác thực đặt lại mật khẩu.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Email đăng ký',
                      controller: _emailController,
                      hintText: 'example@email.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Gửi mã xác nhận',
                      trailingIcon: Icons.arrow_forward,
                      backgroundColor: AppColors.primaryContainer,
                      onPressed: _handleSend,
                    ),
                    if (_sent) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.secondary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đã gửi mã thành công! Vui lòng kiểm tra hộp thư.',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text('Nhớ lại mật khẩu? Quay lại đăng nhập',
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
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
