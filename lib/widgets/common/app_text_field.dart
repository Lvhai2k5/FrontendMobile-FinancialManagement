import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.inputFormatters,
    this.autofillHints,
    this.validator,
    this.fieldKey,
    this.compact = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.titleSm
                .copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          key: fieldKey,
          controller: controller,
          validator: validator,
          autovalidateMode: validator == null
              ? AutovalidateMode.disabled
              : AutovalidateMode.onUserInteraction,
          obscureText: obscureText,
          autocorrect:
              !obscureText && keyboardType != TextInputType.emailAddress,
          enableSuggestions: !obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.primary),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: AppColors.outline,
                    ),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: AppColors.pastelBlush.withValues(alpha: 0.6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            errorStyle: AppTypography.bodySm.copyWith(color: AppColors.error),
            errorMaxLines: 3,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14, vertical: compact ? 12 : 16),
          ),
        ),
      ],
    );
  }
}
