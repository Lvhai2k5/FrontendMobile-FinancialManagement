import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/brand_wordmark.dart';
import '../../widgets/common/terms_sheet.dart';

/// Màn hình chào mừng — thiết kế theo `screen0_2`: logo, ảnh gia đình,
/// tiêu đề, nút "Bắt đầu ngay" và ô đồng ý chính sách bảo mật.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _agreed = true;

  void _getStarted() {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý Chính sách bảo mật để tiếp tục.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F5), Color(0xFFFDEBE5), Color(0xFFFFF8F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const BrandWordmark(logoSize: 44, fontSize: 30),
                const Spacer(flex: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/family_hero.png',
                      width: double.infinity, fit: BoxFit.fitWidth),
                ),
                const SizedBox(height: 28),
                Text.rich(
                  TextSpan(
                    text: 'Gọn tài chính,\n',
                    style: AppTypography.headlineLgMobile
                        .copyWith(fontSize: 30, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(
                        text: 'vững tương lai',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 4),
                AppButton(
                  label: 'Bắt đầu ngay',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: _getStarted,
                ),
                const SizedBox(height: 14),
                _ConsentRow(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v),
                  onOpenPolicy: () async {
                    final ok = await showTermsSheet(context);
                    if (ok == true) setState(() => _agreed = true);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow(
      {required this.value,
      required this.onChanged,
      required this.onOpenPolicy});

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenPolicy;

  @override
  Widget build(BuildContext context) {
    final base =
        AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: 'Tôi đồng ý với ',
              style: base,
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onOpenPolicy,
                    child: Text(
                      'Chính sách bảo mật',
                      style: base.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                TextSpan(
                  text: '',
                  style: base.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' của FinNest'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
