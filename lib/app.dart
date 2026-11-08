import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/family_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'routes/app_routes.dart';

class FinanceManagementApp extends StatelessWidget {
  const FinanceManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'FinNest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: AppRoutes.navigatorKey,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
