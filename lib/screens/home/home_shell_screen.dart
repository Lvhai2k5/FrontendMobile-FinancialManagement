import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/family_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/layout/bottom_nav_bar.dart';
import '../../widgets/layout/home_app_bar.dart';
import '../../widgets/layout/home_tab_header.dart';
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

class _HomeShellScreenState extends State<HomeShellScreen>
    with WidgetsBindingObserver {
  int _index = 0;
  TransactionProvider? _transactions;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    // Vào app là tải dữ liệu thật của tài khoản đang đăng nhập từ Backend.
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transactions = context.read<TransactionProvider>()
        ..addListener(_scheduleRetry);
      _reloadAll();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _transactions?.removeListener(_scheduleRetry);
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _transactions != null) {
      _reloadAll();
    }
  }

  void _scheduleRetry() {
    if (_transactions?.hasPendingRetry != true) {
      _retryTimer?.cancel();
      _retryTimer = null;
      return;
    }
    _retryTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _sync();
      }
    });
  }

  Future<void> _reloadAll() async {
    final user = context.read<UserProvider>();
    final transactions = context.read<TransactionProvider>();
    await user.load();
    if (!mounted) return;
    if (user.user case final profile?) {
      await transactions.setSession(profile.personId);
    }
    if (!mounted) return;
    await Future.wait([
      context.read<FamilyProvider>().load(),
      transactions.load(),
      context.read<NotificationProvider>().load(),
    ]);
    if (mounted) await _sync();
  }

  Future<void> _sync() async {
    final families = context.read<FamilyProvider>();
    final notifications = context.read<NotificationProvider>();
    final count = await context.read<TransactionProvider>().syncPending();
    if (mounted && count > 0) {
      await Future.wait([families.load(), notifications.load()]);
    }
  }

  static const _items = [
    BottomNavItemData(icon: Icons.home_outlined, label: 'Tổng quan'),
    BottomNavItemData(icon: Icons.groups_outlined, label: 'Gia đình'),
    BottomNavItemData(icon: Icons.swap_horiz, label: 'Giao dịch'),
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
      backgroundColor: HomeTabColors.canvas,
      appBar: const HomeAppBar(emphasizeBrand: true),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavBar(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
