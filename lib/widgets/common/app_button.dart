import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Kiểu nút theo mục "Buttons" trong `DESIGN.md` (Primary/Secondary, pill-shaped).
enum AppButtonVariant { primary, secondary }

/// Widget thuần túy, tái sử dụng — chỉ nhận dữ liệu qua constructor/callback,
/// không biết gì về nghiệp vụ gọi nó.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Icon tùy biến (ví dụ logo SSO nhiều màu) khi 1 `IconData` không đủ.
  /// Ưu tiên hơn [leadingIcon] nếu cả 2 cùng được truyền.
  final Widget? leadingWidget;

  /// Ghi đè màu nền mặc định của variant (ví dụ CTA hero riêng của 1 màn).
  final Color? backgroundColor;

  bool get _isPrimary => variant == AppButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget!,
          const SizedBox(width: 8),
        ] else if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: 18,
            color: _isPrimary ? Colors.white : AppColors.secondary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.titleSm.copyWith(
            color: _isPrimary ? Colors.white : AppColors.onSurface,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(
            trailingIcon,
            size: 18,
            color: _isPrimary ? Colors.white : AppColors.secondary,
          ),
        ],
      ],
    );

    final resolvedBackground = backgroundColor ??
        (_isPrimary
            ? AppColors.primaryContainer
            : Colors.white.withValues(alpha: 0.8));

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(999),
        shadowColor: _isPrimary
            ? resolvedBackground.withValues(alpha: 0.35)
            : AppColors.ctaSecondaryBorder.withValues(alpha: 0.15),
        elevation: _isPrimary ? 8 : 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: _isPrimary
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.ctaSecondaryBorder),
                  ),
            child: content,
          ),
        ),
      ),
    );
  }
}
