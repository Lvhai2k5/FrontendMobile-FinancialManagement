import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:finance_management/app.dart';
import 'package:finance_management/api/auth_api.dart';
import 'package:finance_management/providers/auth_provider.dart';
import 'package:finance_management/config/theme.dart';
import 'package:finance_management/screens/login/login_screen.dart';
import 'package:finance_management/screens/otp/otp_verify_screen.dart';
import 'package:finance_management/screens/register/register_screen.dart';

class _RegistrationApi extends AuthApi {
  int calls = 0;
  String? submittedPhone;

  @override
  Future<void> register(
      {required String name,
      required String username,
      required String email,
      required String phone,
      required String password}) async {
    calls++;
    submittedPhone = phone;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final introFont = FontLoader(IntroTypography.fontFamily)
      ..addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-Regular.ttf'))
      ..addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-SemiBold.ttf'))
      ..addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-Medium.ttf'))
      ..addFont(
          rootBundle.load('assets/fonts/be-vietnam-pro/BeVietnamPro-Bold.ttf'))
      ..addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-ExtraBold.ttf'));
    await introFont.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  Future<void> openApp(WidgetTester tester, Size size,
      {double textScale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const RepaintBoundary(
      key: ValueKey('preview'),
      child: FinanceManagementApp(),
    ));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(FinanceManagementApp));
      await precacheImage(const AssetImage('assets/images/logo.jpg'), context);
      await precacheImage(
          const AssetImage('assets/images/family_hero.png'), context);
      await precacheImage(
          const AssetImage('assets/images/google_logo.png'), context);
    });
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_UI')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('preview')));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('build/ui-review');
      await directory.create(recursive: true);
      await File('${directory.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  Future<void> openRegistration(WidgetTester tester, _RegistrationApi api,
      {Size size = const Size(390, 844), double textScale = 1}) async {
    await openApp(tester, size, textScale: textScale);
    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    navigator.push(MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
              create: (_) => AuthProvider(authApi: api),
              child: const RegisterScreen(),
            )));
    await tester.pumpAndSettle();
  }

  testWidgets('Đăng ký báo lỗi từng ô và chặn API khi dữ liệu sai',
      (tester) async {
    final api = _RegistrationApi();
    await openRegistration(tester, api);
    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    expect(find.textContaining('✨'), findsNothing);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    expect(tester.widget<Text>(find.text('Gmail')).style?.fontSize, 16);
    await capture(tester, 'register');
    final submit = find.text('Tạo tài khoản ngay');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    for (final error in [
      'Vui lòng nhập họ và tên.',
      'Vui lòng nhập Gmail.',
      'Vui lòng nhập số điện thoại.',
      'Vui lòng nhập tên tài khoản.',
      'Vui lòng nhập mật khẩu.',
      'Vui lòng xác nhận mật khẩu.'
    ]) {
      expect(find.text(error), findsOneWidget);
    }
    expect(api.calls, 0);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'sai-email');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gmail không đúng định dạng'), findsOneWidget);
    await tester.enterText(fields.at(1), 'finnest.review@gmail.com');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gmail không đúng định dạng'), findsNothing);
    await tester.ensureVisible(find.text('Họ và tên'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await capture(tester, 'register-errors');
  });

  testWidgets('Đăng ký hợp lệ chuẩn hóa điện thoại rồi chuyển sang OTP',
      (tester) async {
    final api = _RegistrationApi();
    await openRegistration(tester, api);
    final fields = find.byType(TextFormField);
    const values = [
      'Nguyễn An',
      'finnest.review@gmail.com',
      '0912 345 678',
      'review_user',
      'Abc12345',
      'Abc12345'
    ];
    for (var i = 0; i < values.length; i++) {
      await tester.ensureVisible(fields.at(i));
      await tester.enterText(fields.at(i), values[i]);
      await tester.pumpAndSettle();
    }
    // Đổi mật khẩu phải cập nhật lỗi xác nhận, không giữ kết quả cũ.
    await tester.enterText(fields.at(4), 'Abc123456');
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận mật khẩu không khớp.'), findsOneWidget);
    await tester.enterText(fields.at(5), 'Abc123456');
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận mật khẩu không khớp.'), findsNothing);
    final consent = find.byKey(const ValueKey('register-consent'));
    await tester.ensureVisible(consent);
    await tester.tap(consent);
    await tester.pumpAndSettle();
    expect(find.text('Điều khoản & Chính sách'), findsOneWidget);
    await tester.tap(find.text('Tôi đã hiểu & Đồng ý'));
    await tester.pumpAndSettle();
    final submit = find.text('Tạo tài khoản ngay');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(api.calls, 1);
    expect(api.submittedPhone, '0912345678');
    expect(find.byType(OtpVerifyScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Đồng ý điều khoản qua bảng như ban đầu, hủy không tích ô',
      (tester) async {
    await openRegistration(tester, _RegistrationApi(),
        size: const Size(360, 800), textScale: 1.3);
    for (final field
        in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.decoration?.helperText, isNull);
    }
    final consent = find.byKey(const ValueKey('register-consent'));
    await tester.ensureVisible(consent);
    await tester.tap(consent);
    await tester.pumpAndSettle();
    expect(find.text('Điều khoản & Chính sách'), findsOneWidget);
    expect(find.text('Tôi đã hiểu & Đồng ý'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(consent).properties.checked, isFalse);
    await tester.tap(consent);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tôi đã hiểu & Đồng ý'));
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(consent).properties.checked, isTrue);
    await tester.tap(consent);
    await tester.pumpAndSettle();
    expect(tester.widget<Semantics>(consent).properties.checked, isFalse);
    expect(find.text('Điều khoản & Chính sách'), findsNothing);
    expect(tester.takeException(), isNull);
    await capture(tester, 'register-consent');
  });

  testWidgets('Welcome dùng font mới và hạ mũi tên theo thân chữ',
      (tester) async {
    await openApp(tester, const Size(390, 844));
    final label = find.text('Bắt đầu ngay');
    final arrow = find.byIcon(Icons.arrow_forward);
    expect(label, findsOneWidget);
    expect(tester.widget<Text>(label).style?.fontFamily,
        IntroTypography.fontFamily);
    expect(tester.getCenter(arrow).dy - tester.getCenter(label).dy,
        closeTo(2, 0.1));
    expect(tester.takeException(), isNull);
    await capture(tester, 'welcome');

    await tester.tap(label);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'login');
  });

  testWidgets('Điều khoản và chính sách mở, đổi tab và xác nhận được',
      (tester) async {
    await openApp(tester, const Size(390, 844));
    await tester.tap(find.text('Chính sách bảo mật'));
    await tester.pumpAndSettle();
    expect(find.text('Điều khoản & Chính sách'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'terms');

    await tester.tap(find.text('Chính sách bảo mật').last);
    await tester.pumpAndSettle();
    expect(find.text('Dữ liệu chúng tôi thu thập'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'privacy');

    await tester.tap(find.text('Tôi đã hiểu & Đồng ý'));
    await tester.pumpAndSettle();
    expect(find.text('Điều khoản & Chính sách'), findsNothing);
  });

  testWidgets('Theme và màn OTP dùng Be Vietnam Pro', (tester) async {
    await openApp(tester, const Size(390, 844));
    expect(AppTypography.fontFamily, 'BeVietnamPro');
    expect(AppTheme.light.textTheme.bodyMedium?.fontFamily, 'BeVietnamPro');
    expect(AppTypography.brandTitle.fontFamily, 'BeVietnamPro');
    final navigator =
        tester.state<NavigatorState>(find.byType(Navigator).first);
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => const OtpVerifyScreen(
        args: OtpVerifyArgs(
          email: 'finnest.review@gmail.com',
          purpose: OtpPurpose.register,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(OtpVerifyScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'otp');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Welcome và chính sách không tràn trên màn nhỏ, chữ lớn',
      (tester) async {
    await openApp(tester, const Size(360, 800), textScale: 1.3);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Chính sách bảo mật'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await capture(tester, 'terms-large-text');
  });
}
