import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Hộp thoại nhập 1 dòng chữ/số — trả về chuỗi đã trim, hoặc `null` nếu huỷ.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? message,
  String confirmLabel = 'Xác nhận',
  String initialValue = '',
  TextInputType keyboardType = TextInputType.text,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTypography.headlineSm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null) ...[
            Text(message,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text.trim()),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
