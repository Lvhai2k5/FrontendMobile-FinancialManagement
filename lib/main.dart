import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/api_client.dart';
import 'app.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Refresh token hết hạn -> về màn đăng nhập.
  onSessionExpired = () => AppRoutes.navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  runApp(const FinanceManagementApp());
}
