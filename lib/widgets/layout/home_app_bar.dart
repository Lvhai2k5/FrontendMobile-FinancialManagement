import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';

/// Thanh app bar dùng chung cho 4 tab chính: logo + tên thương hiệu bên
/// trái, chuông thông báo bên phải (điều hướng sang màn Thông báo).
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUnread =
        context.watch<NotificationProvider>().notifications.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/logo.jpg',
                  width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            Text('FinNest',
                style: AppTypography.headlineSm
                    .copyWith(color: AppColors.secondary)),
            const Spacer(),
            Material(
              color: AppColors.surfaceContainerLowest,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.notifications),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none,
                          color: AppColors.onSurfaceVariant),
                      if (hasUnread)
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(52);
}
