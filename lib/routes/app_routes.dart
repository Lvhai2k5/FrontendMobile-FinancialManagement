import 'package:flutter/material.dart';

import '../screens/family/family_detail_screen.dart';
import '../screens/family/threshold_config_screen.dart';
import '../screens/forgot_password/forgot_password_screen.dart';
import '../screens/home/home_shell_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/otp/otp_verify_screen.dart';
import '../screens/register/register_screen.dart';
import '../screens/reset_password/reset_password_screen.dart';
import '../screens/transaction/transaction_form_screen.dart';
import '../screens/welcome/welcome_screen.dart';

/// Bản đồ tên route ↔ Screen. Thêm route mới ở đây khi thêm screen mới,
/// không điều hướng bằng `MaterialPageRoute` rải rác trong `screens/`.
class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerify = '/otp-verify';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String familyDetail = '/family-detail';
  static const String thresholdConfig = '/threshold-config';
  static const String notifications = '/notifications';
  static const String transactionForm = '/transaction-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otpVerify:
        return MaterialPageRoute(
          builder: (_) =>
              OtpVerifyScreen(args: settings.arguments as OtpVerifyArgs),
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
              args: settings.arguments as ResetPasswordArgs),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShellScreen());
      case familyDetail:
        return MaterialPageRoute(
          builder: (_) =>
              FamilyDetailScreen(familyId: settings.arguments as int),
        );
      case thresholdConfig:
        return MaterialPageRoute(
          builder: (_) => ThresholdConfigScreen(
              args: settings.arguments as ThresholdConfigArgs),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case transactionForm:
        return MaterialPageRoute(
            builder: (_) => const TransactionFormScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Không tìm thấy route: ${settings.name}')),
          ),
        );
    }
  }
}
