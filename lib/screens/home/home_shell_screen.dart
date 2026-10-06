import 'package:flutter/material.dart';

import '../../widgets/layout/bottom_nav_bar.dart';
import '../../widgets/layout/home_app_bar.dart';
import '../family/family_list_tab.dart';
import '../profile/profile_tab.dart';
import '../transaction/transaction_list_tab.dart';
import 'overview_tab.dart';

/// Khung sườn sau đăng nhập — giữ `IndexedStack` của 4 tab chính để mỗi tab
/// không mất state khi chuyển qua lại, cộng thanh app bar/bottom nav dùng
/// chung. Đăng ký ở route `AppRoutes.home`.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

  static const _items = [
    BottomNavItemData(icon: Icons.grid_view_rounded, label: 'Tổng quan'),
    BottomNavItemData(icon: Icons.diversity_3, label: 'Gia đình'),
    BottomNavItemData(icon: Icons.receipt_long, label: 'Giao dịch'),
    BottomNavItemData(icon: Icons.person_outline, label: 'Người dùng'),
  ];

  static const _tabs = [
    OverviewTab(),
    FamilyListTab(),
    TransactionListTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavBar(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
