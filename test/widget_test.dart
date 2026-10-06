import 'package:flutter_test/flutter_test.dart';

import 'package:finance_management/app.dart';

void main() {
  testWidgets('WelcomeScreen hiển thị thương hiệu và 2 nút hành động',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceManagementApp());
    await tester.pumpAndSettle();

    expect(find.text('FinNest'), findsOneWidget);
    expect(find.text('Bắt Đầu Ngay'), findsOneWidget);
    expect(find.text('Hướng dẫn sử dụng'), findsOneWidget);
  });

  testWidgets('Bắt Đầu Ngay điều hướng sang màn hình đăng nhập',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceManagementApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bắt Đầu Ngay'));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại! 👋'), findsOneWidget);
    expect(find.text('Tên tài khoản'), findsOneWidget);
    expect(find.text('Đăng Nhập Ngay'), findsOneWidget);
  });
}
