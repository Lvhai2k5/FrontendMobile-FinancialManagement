import 'package:flutter/material.dart';

import '../../config/theme.dart';

enum PasswordStrength { empty, weak, medium, good, strong }

PasswordStrength evaluatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  var score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  return switch (score) {
    0 || 1 => PasswordStrength.weak,
    2 => PasswordStrength.medium,
    3 => PasswordStrength.good,
    _ => PasswordStrength.strong,
  };
}

/// 4 thanh + nhãn độ mạnh mật khẩu — widget thuần túy, nhận [strength] đã
/// được tính sẵn (qua [evaluatePasswordStrength]) từ `screens/`.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.strength});

  final PasswordStrength strength;

  int get _filledBars => switch (strength) {
        PasswordStrength.empty => 0,
        PasswordStrength.weak => 1,
        PasswordStrength.medium => 2,
        PasswordStrength.good => 3,
        PasswordStrength.strong => 4,
      };

  String get _label => switch (strength) {
        PasswordStrength.empty => '',
        PasswordStrength.weak => 'Yếu',
        PasswordStrength.medium => 'Trung bình',
        PasswordStrength.good => 'Khá',
        PasswordStrength.strong => 'Tốt',
      };

  Color get _color => switch (strength) {
        PasswordStrength.weak => AppColors.error,
        PasswordStrength.medium => AppColors.pastelPeach,
        PasswordStrength.good => AppColors.primary,
        PasswordStrength.strong => AppColors.secondary,
        PasswordStrength.empty => AppColors.surfaceContainer,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < _filledBars;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? _color : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (strength != PasswordStrength.empty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tối thiểu 8 ký tự, gồm chữ và số',
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.outline)),
              Text('Độ mạnh: $_label',
                  style:
                      AppTypography.labelSm.copyWith(color: _color)),
            ],
          ),
        ],
      ],
    );
  }
}
