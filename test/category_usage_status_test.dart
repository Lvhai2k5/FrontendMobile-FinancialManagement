import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_management/config/theme.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/screens/home/overview_dashboard.dart';
import 'package:finance_management/utils/category_usage_status.dart';

FinancialCategoryModel jar(
        {int id = 1,
        double spent = 0,
        double limit = 100,
        double warning = 80,
        double emergency = 100,
        double approval = 0,
        CategoryStatus status = CategoryStatus.active}) =>
    FinancialCategoryModel(
        financialCategoryId: id,
        name: 'Hũ $id',
        allocationPercent: 50,
        spent: spent,
        limitAmount: limit,
        status: status,
        amountOfWarning: warning,
        amountOfEmergency: emergency,
        amountOfApproval: approval);

void main() {
  test('Đọc ngưỡng riêng từng hũ, so sánh tiền thật trước khi làm tròn %', () {
    expect(categoryUsageStatus(jar(spent: 79.99)), CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(spent: 80)), CategoryUsageStatus.warning);
    expect(categoryUsageStatus(jar(spent: 60, warning: 60)),
        CategoryUsageStatus.warning);
    expect(categoryUsageStatus(jar(spent: 88, warning: 90)),
        CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(spent: 79.99, emergency: 80)),
        CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(spent: 80, emergency: 80)),
        CategoryUsageStatus.emergency);
  });

  test('Đỏ tại đúng 100%, vượt hạn mức, emergency và khoá ưu tiên hơn warning',
      () {
    expect(categoryUsageStatus(jar(spent: 100)), CategoryUsageStatus.depleted);
    expect(categoryUsageStatus(jar(spent: 200)), CategoryUsageStatus.depleted);
    expect(categoryUsageStatus(jar(spent: 75, emergency: 70)),
        CategoryUsageStatus.emergency);
    expect(categoryUsageStatus(jar(spent: 0, status: CategoryStatus.locked)),
        CategoryUsageStatus.locked);
    expect(categoryUsageStatus(jar(spent: 200, status: CategoryStatus.locked)),
        CategoryUsageStatus.locked);
  });

  test('Ngưỡng 0 tắt, không fallback 80/85%, approval không đổi trạng thái',
      () {
    expect(
        categoryUsageStatus(
            jar(spent: 99, warning: 0, emergency: 0, approval: 1)),
        CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(spent: 100, warning: 0, emergency: 0)),
        CategoryUsageStatus.depleted);
    expect(categoryUsageStatus(jar(spent: 80, warning: 0)),
        CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(spent: 95, warning: 90, emergency: 0)),
        CategoryUsageStatus.warning);
    expect(categoryUsageStatus(jar(spent: 0, warning: 0, emergency: 0)),
        CategoryUsageStatus.normal);
  });

  test('Hũ chưa hạn mức không chia cho 0, vẫn đọc ngưỡng tiền đang bật', () {
    expect(
        categoryUsageStatus(jar(limit: 0, spent: 90, warning: 0, emergency: 0)),
        CategoryUsageStatus.normal);
    expect(categoryUsageStatus(jar(limit: 0, spent: 80)),
        CategoryUsageStatus.warning);
    expect(categoryUsageStatus(jar(limit: 0, spent: 100)),
        CategoryUsageStatus.emergency);
  });

  testWidgets(
      'Màu progress, phần trăm, nhãn và cảnh báo cùng một trạng thái; đổi ngưỡng cập nhật ngay',
      (tester) async {
    tester.view.physicalSize = const Size(320, 1800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    Future<void> show(List<FinancialCategoryModel> categories) async {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: OverviewJars(categories: categories)))));
      await tester.pumpAndSettle();
    }

    final categories = [
      jar(id: 1, spent: 88, warning: 90),
      jar(id: 2, spent: 60, warning: 60),
      jar(id: 3, spent: 75, emergency: 70),
      jar(id: 4, spent: 100),
      jar(id: 5, status: CategoryStatus.locked),
    ];
    await show(categories);
    final expected = [
      ('Trong ngưỡng', AppColors.secondary),
      ('Cảnh báo', const Color(0xFFB45309)),
      ('Khẩn cấp', AppColors.error),
      ('Hết hạn mức', AppColors.error),
      ('Đang khóa', AppColors.error),
    ];
    for (var i = 0; i < expected.length; i++) {
      final row = find.byKey(ValueKey('overview-jar-${i + 1}'));
      expect(find.descendant(of: row, matching: find.text(expected[i].$1)),
          findsOneWidget);
      final progress = tester.widget<LinearProgressIndicator>(find.descendant(
          of: row, matching: find.byType(LinearProgressIndicator)));
      expect(progress.color, expected[i].$2);
      final percentage = tester.widget<Text>(find.descendant(
          of: row, matching: find.text('${categories[i].spent.round()}%')));
      expect(percentage.style?.color, expected[i].$2);
    }
    expect(find.text('4 hũ cần chú ý'), findsOneWidget);
    for (final label in [
      'Cảnh báo: 1',
      'Khẩn cấp: 1',
      'Hết hạn mức: 1',
      'Đang khóa: 1'
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    // Same spent/limit, a different configured warning: the banner must follow.
    await show([jar(spent: 60, warning: 60)]);
    expect(find.text('1 hũ cần chú ý'), findsOneWidget);
    await show([jar(spent: 60, warning: 70)]);
    expect(find.byKey(const ValueKey('overview-jar-alert')), findsNothing);
    expect(find.text('Trong ngưỡng'), findsOneWidget);
    await tester.tap(find.text('Hũ 1'));
    await tester.pumpAndSettle();
    expect(find.text('Ngưỡng cảnh báo: 70 đ'), findsOneWidget);
    expect(find.text('Ngưỡng khẩn cấp: 100 đ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
