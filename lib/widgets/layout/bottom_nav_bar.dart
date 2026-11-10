import 'package:flutter/material.dart';

import '../../config/theme.dart';
import 'home_tab_header.dart';

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
          height: 78 +
              (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(0, 32) *
                  2,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Center(
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? HomeTabColors.sageTint
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: selected
                                ? HomeTabColors.sage
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: AppTypography.labelSm.copyWith(
                              color: selected
                                  ? HomeTabColors.sage
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
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
