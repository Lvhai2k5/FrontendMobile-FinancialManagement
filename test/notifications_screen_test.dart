import 'package:finance_management/models/notification_model.dart';
import 'package:finance_management/providers/notification_provider.dart';
import 'package:finance_management/screens/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Notifications extends NotificationProvider {
  @override
  List<NotificationModel> get notifications => const [
        NotificationModel(
          id: 1,
          kind: NotificationKind.thresholdWarning,
          title: 'Cảnh báo hạn mức hũ',
          message: 'Hũ đã chạm ngưỡng cảnh báo.',
          timeLabel: 'Hiện tại',
        ),
      ];

  @override
  Future<void> load() async {}
}

void main() {
  testWidgets('Có thể đổi bộ lọc thông báo khi mục Giao dịch rỗng',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => _Notifications(),
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );

    final all = find.widgetWithText(ChoiceChip, 'Tất cả (1)');
    final transactions = find.widgetWithText(ChoiceChip, 'Giao dịch (0)');
    final thresholds = find.widgetWithText(ChoiceChip, 'Hạn mức (1)');
    final warning = find.text('Cảnh báo hạn mức hũ');
    final empty = find.text('Không có thông báo mới.');
    expect(warning, findsOneWidget);

    await tester.tap(transactions);
    await tester.pumpAndSettle();

    expect(all, findsOneWidget);
    expect(tester.widget<ChoiceChip>(transactions).selected, isTrue);
    expect(thresholds, findsOneWidget);
    expect(empty, findsOneWidget);
    expect(warning, findsNothing);

    await tester.tap(thresholds);
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(thresholds).selected, isTrue);
    expect(warning, findsOneWidget);
    expect(empty, findsNothing);

    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(tester.widget<ChoiceChip>(all).selected, isTrue);
    expect(warning, findsOneWidget);
  });
}
