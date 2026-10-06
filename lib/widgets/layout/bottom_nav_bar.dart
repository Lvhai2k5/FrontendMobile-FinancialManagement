import 'package:flutter/material.dart';

import '../../config/theme.dart';

class BottomNavItemData {
  const BottomNavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Thanh điều hướng 4 tab dưới cùng (Tổng quan/Gia đình/Giao dịch/Người
/// dùng) — widget khung sườn dùng chung, chỉ nhận [currentIndex]/[onTap] từ
/// `screens/home/home_shell_screen.dart`, không tự giữ state điều hướng.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainer)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTypography.labelSm.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
