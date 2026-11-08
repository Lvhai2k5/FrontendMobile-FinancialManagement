import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Logo + chữ "FinNest" (Fin đen, Nest nâu đỏ) dùng ở đầu các màn hình.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.logoSize = 40,
    this.fontSize = 26,
    this.wordmarkColor,
  });

  final double logoSize;
  final double fontSize;
  final Color? wordmarkColor;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.brandTitle.copyWith(
      fontSize: fontSize,
      color: wordmarkColor,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(logoSize * 0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSize * 0.25),
            child: Image.asset('assets/images/logo.jpg',
                width: logoSize, height: logoSize, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            text: 'Fin',
            style: style,
            children: [
              TextSpan(
                  text: 'Nest',
                  style: style.copyWith(
                      color: wordmarkColor ?? AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
