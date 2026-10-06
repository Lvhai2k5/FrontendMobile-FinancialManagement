import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';

/// Màn hình chào mừng (splash/onboarding) — điểm chạm đầu tiên của app,
/// giới thiệu thương hiệu "FinNest" và dẫn người dùng vào luồng đăng ký
/// hoặc xem hướng dẫn sử dụng.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sẽ có ở bản cập nhật tiếp theo.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const _BrandHero(),
                  const Spacer(flex: 4),
                  _ActionButtons(
                      onComingSoon: _showComingSoon,
                      onGetStarted: () {
                        Navigator.of(context).pushNamed(AppRoutes.login);
                      }),
                  const SizedBox(height: 8),
                  const _TermsFootnote(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 vầng sáng pastel mờ ở nền — thuần trang trí, không mang dữ liệu.
class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -96,
            left: -64,
            child:
                _glowCircle(320, AppColors.pastelBlush.withValues(alpha: 0.3)),
          ),
          Positioned(
            top: 220,
            right: -80,
            child: _glowCircle(
                320, AppColors.pastelLavender.withValues(alpha: 0.4)),
          ),
          Positioned(
            bottom: -96,
            left: 100,
            child:
                _glowCircle(360, AppColors.pastelSage.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Logo + tên thương hiệu + tagline.
class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD7A096).withValues(alpha: 0.18),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFF0EC)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC88C82).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: AppColors.pastelPeach,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('FinNest', style: AppTypography.brandTitle),
        const SizedBox(height: 8),
        Text(
          'Gọn tài chính, vững tương lai',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons(
      {required this.onComingSoon, required this.onGetStarted});

  final void Function(BuildContext context, String feature) onComingSoon;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Bắt Đầu Ngay',
          trailingIcon: Icons.arrow_forward,
          backgroundColor: AppColors.ctaPrimary,
          onPressed: onGetStarted,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Hướng dẫn sử dụng',
          leadingIcon: Icons.help_outline,
          variant: AppButtonVariant.secondary,
          onPressed: () => onComingSoon(context, 'Hướng dẫn sử dụng'),
        ),
      ],
    );
  }
}

class _TermsFootnote extends StatelessWidget {
  const _TermsFootnote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Bằng việc tiếp tục, bạn đồng ý với Điều khoản dịch vụ & Chính sách của FinNest.',
      textAlign: TextAlign.center,
      style: AppTypography.labelSm.copyWith(
        color: AppColors.outline.withValues(alpha: 0.8),
      ),
    );
  }
}
