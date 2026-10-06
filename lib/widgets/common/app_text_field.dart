import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Ô nhập liệu thuần túy, tái sử dụng — theo mục "Input Fields" trong
/// `DESIGN.md`. Không tự giữ state ẩn/hiện mật khẩu, nhận qua props/callback.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelMd
                .copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(prefixIcon, size: 20, color: AppColors.outline),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  autofillHints: autofillHints,
                  style:
                      AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (onToggleObscure != null)
                IconButton(
                  onPressed: onToggleObscure,
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: AppColors.outline,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
