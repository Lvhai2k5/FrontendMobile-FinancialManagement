import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finance_management/providers/auth_provider.dart';
import 'package:finance_management/routes/app_routes.dart';
import 'package:finance_management/screens/login/login_screen.dart';

class _GoogleLoginProvider extends AuthProvider {
  _GoogleLoginProvider({this.succeeds = true, this.message});

  final bool succeeds;
  final String? message;
  int calls = 0;
  String? username;

  @override
  Future<bool> loginWithGoogle() async {
    calls++;
    errorMessage = message;
    return succeeds;
  }

  @override
  Future<bool> login(
      {required String username, required String password}) async {
    this.username = username;
    return succeeds;
  }
}

void main() {
  testWidgets('Login accepts email identifier and navigates on success',
      (tester) async {
    final auth = _GoogleLoginProvider();
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text('Home screen')),
        },
      ),
    ));

    await tester.enterText(find.byType(TextFormField).first, 'an@yahoo.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Đăng Nhập Ngay'));
    await tester.pumpAndSettle();

    expect(auth.username, 'an@yahoo.com');
    expect(find.text('Home screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google login button calls auth and navigates on success',
      (tester) async {
    final auth = _GoogleLoginProvider();
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        navigatorKey: AppRoutes.navigatorKey,
        home: const LoginScreen(),
        routes: {
          AppRoutes.home: (_) => const Scaffold(body: Text('Home screen')),
        },
      ),
    ));

    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pumpAndSettle();

    expect(auth.calls, 1);
    expect(find.text('Home screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google login shows backend error in Vietnamese', (tester) async {
    final auth = _GoogleLoginProvider(
      succeeds: false,
      message: 'Email Google này chưa được liên kết với tài khoản FinNest nào.',
    );
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: const MaterialApp(home: LoginScreen()),
    ));

    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pump();

    expect(auth.calls, 1);
    expect(find.textContaining('chưa được liên kết'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
