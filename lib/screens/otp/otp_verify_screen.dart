import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/otp_input.dart';
import '../reset_password/reset_password_screen.dart';

/// Lý do màn OTP được mở — quyết định nơi điều hướng tới sau khi xác thực
/// thành công: `register` quay lại đăng nhập, `resetPassword` sang màn đặt
/// mật khẩu mới.
enum OtpPurpose { register, resetPassword }

class OtpVerifyArgs {
  const OtpVerifyArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

/// Màn xác thực mã OTP dùng chung cho luồng Đăng ký & Quên mật khẩu. Backend
/// chưa có endpoint gửi/xác thực OTP nên mã hợp lệ được mô phỏng cố định là
/// `000000`, đủ để review được toàn bộ luồng UI trước khi có API thật.
class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.args});

  final OtpVerifyArgs args;

  static const String demoValidCode = '000000';

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String _code = '';
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _maskedEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return email;
    return '${email.substring(0, 1)}***${email.substring(at)}';
  }

  void _handleConfirm() {
    if (_code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_code != OtpVerifyScreen.demoValidCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Mã không đúng — dùng mã demo ${OtpVerifyScreen.demoValidCode} để tiếp tục.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    switch (widget.args.purpose) {
      case OtpPurpose.register:
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo tài khoản thành công! Hãy đăng nhập.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
        break;
      case OtpPurpose.resetPassword:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.resetPassword,
          arguments: ResetPasswordArgs(email: widget.args.email),
        );
        break;
    }
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
              const SizedBox(height: 24),
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
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mark_email_read_outlined,
                          color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text('Xác thực mã OTP ✉️',
                        style: AppTypography.headlineSm),
                    const SizedBox(height: 8),
                    Text(
                      'Mã xác thực 6 chữ số đã được gửi đến email của bạn:',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(_maskedEmail(widget.args.email),
                        style: AppTypography.titleSm),
                    const SizedBox(height: 24),
                    OtpInput(onCompleted: (code) => _code = code),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule,
                            size: 16, color: AppColors.outline),
                        const SizedBox(width: 6),
                        Text('Chưa nhận được mã? ',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.onSurfaceVariant)),
                        GestureDetector(
                          onTap: _secondsLeft == 0 ? _startCountdown : null,
                          child: Text(
                            _secondsLeft == 0
                                ? 'Gửi lại mã'
                                : 'Gửi lại sau (${_secondsLeft}s)',
                            style: AppTypography.labelMd.copyWith(
                              color: _secondsLeft == 0
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Xác nhận mã OTP',
                      trailingIcon: Icons.arrow_forward,
                      backgroundColor: AppColors.primaryContainer,
                      onPressed: _handleConfirm,
                    ),
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
                          Icon(Icons.lightbulb_outline,
                              size: 18, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kiểm tra thêm mục Thư rác (Spam) nếu bạn chưa thấy mã sau ít phút. Mã demo: ${OtpVerifyScreen.demoValidCode}.',
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Text('Quay lại',
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
