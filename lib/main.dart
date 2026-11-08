import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'app.dart';
import 'providers/family_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Refresh token hết hạn -> về màn đăng nhập.
  onSessionExpired = () {
    final navigator = AppRoutes.navigatorKey.currentState;
    if (navigator == null) return;
    final context = navigator.context;
    context.read<FamilyProvider>().clear();
    context.read<TransactionProvider>().clear();
    context.read<NotificationProvider>().clear();
    context.read<UserProvider>().clear();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  };
  runApp(const FinanceManagementApp());
}
