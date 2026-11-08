import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_management/config/theme.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/providers/family_provider.dart';
import 'package:finance_management/providers/notification_provider.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:finance_management/screens/home/overview_tab.dart';
import 'package:finance_management/screens/home/overview_dashboard.dart';
import 'package:finance_management/widgets/layout/home_app_bar.dart';
import 'package:finance_management/widgets/layout/bottom_nav_bar.dart';

const _family = FamilyDetailModel(
  familyId: 1,
  code: 'DEMO',
  name: 'Gia đình Minh & Lan',
  myRole: MemberRole.owner,
  totalBudget: 61830000,
  budgetGrowthPercent: 0,
  foundedLabel: '',
  members: [],
  totalIncome: 48500000,
  totalExpense: 77670000,
  categories: [
    FinancialCategoryModel(
        financialCategoryId: 1,
        name: 'Nhu cầu thiết yếu',
        allocationPercent: 50,
        spent: 14200000,
        limitAmount: 22000000,
        amountOfWarning: 17600000,
        amountOfEmergency: 22000000,
        status: CategoryStatus.active),
    FinancialCategoryModel(
        financialCategoryId: 2,
        name: 'Giáo dục & con cái',
        allocationPercent: 9,
        spent: 5800000,
        limitAmount: 8000000,
        amountOfWarning: 6400000,
        amountOfEmergency: 8000000,
        status: CategoryStatus.active),
    FinancialCategoryModel(
        financialCategoryId: 3,
        name: 'Tiết kiệm dài hạn',
        allocationPercent: 44,
        spent: 35000000,
        limitAmount: 40000000,
        amountOfWarning: 32000000,
        amountOfEmergency: 40000000,
        status: CategoryStatus.active),
    FinancialCategoryModel(
        financialCategoryId: 4,
        name: 'Hưởng thụ & giải trí',
        allocationPercent: 4,
        spent: 3100000,
        limitAmount: 4000000,
        amountOfWarning: 3200000,
        amountOfEmergency: 4000000,
        status: CategoryStatus.active),
    FinancialCategoryModel(
        financialCategoryId: 5,
        name: 'Quỹ khẩn cấp & y tế',
        allocationPercent: 10,
        spent: 15000000,
        limitAmount: 15000000,
        amountOfWarning: 12000000,
        amountOfEmergency: 15000000,
        status: CategoryStatus.active),
    FinancialCategoryModel(
        financialCategoryId: 6,
        name: 'Cho đi',
        allocationPercent: 5,
        spent: 8830000,
        limitAmount: 12000000,
        amountOfWarning: 9600000,
        amountOfEmergency: 12000000,
        status: CategoryStatus.active),
  ],
);

class _Families extends FamilyProvider {
  int _selection = 1;
  @override
  List<FamilySummaryModel> get families => [
        for (final id in [1, 2])
          FamilySummaryModel(
              familyId: id,
              code: 'TEST$id',
              name: id == 1 ? _family.name : 'Tổ ấm thứ hai',
              myRole: MemberRole.owner,
              totalBudget: 0,
              categoryCount: 0,
              members: const []),
      ];
  @override
  void selectFamily(int id) {
    _selection = id;
    notifyListeners();
  }

  @override
  int? get selectedFamilyId => _selection;
  @override
  FamilyDetailModel? detail(int? familyId) => familyId == 1
      ? _family
      : const FamilyDetailModel(
          familyId: 2,
          code: 'TEST2',
          name: 'Tổ ấm thứ hai',
          myRole: MemberRole.owner,
          totalBudget: 123,
          budgetGrowthPercent: 0,
          foundedLabel: '',
          members: [],
          categories: [],
          totalIncome: 0,
          totalExpense: 0);
}

class _Transactions extends TransactionProvider {
  _Transactions({this.empty = false});
  final bool empty;
  @override
  List<TransactionModel> get transactions {
    if (empty) return [];
    final now = DateTime.now();
    TransactionModel item(
            int id, DateTime date, double amount, TransactionType type) =>
        TransactionModel(
            transactionId: id,
            content: 'Giao dịch minh họa',
            amount: amount,
            type: type,
            status: TransactionStatus.approve,
            categoryName: 'Hũ minh họa',
            createdAt: date,
            familyId: 1);
    return [
      item(1, DateTime(now.year, now.month, 1), 48500000,
          TransactionType.income),
      item(2, DateTime(now.year, now.month, 1), 77670000,
          TransactionType.expense),
      item(3, DateTime(now.year, now.month - 1, 1), 1000,
          TransactionType.expense),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader(AppTypography.fontFamily);
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold'
    ]) {
      font.addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-$weight.ttf'));
    }
    await font.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  Future<void> open(WidgetTester tester,
      {double textScale = 1, bool empty = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(RepaintBoundary(
      key: const ValueKey('overview-preview'),
      child: MultiProvider(
          providers: [
            ChangeNotifierProvider<FamilyProvider>(create: (_) => _Families()),
            ChangeNotifierProvider<TransactionProvider>(
                create: (_) => _Transactions(empty: empty)),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: const Locale('vi'),
            supportedLocales: const [Locale('vi'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Scaffold(
                appBar: const HomeAppBar(emphasizeBrand: true),
                body: const OverviewTab(),
                bottomNavigationBar:
                    BottomNavBar(currentIndex: 0, onTap: (_) {}, items: const [
                  BottomNavItemData(
                      icon: Icons.grid_view_rounded, label: 'Tổng quan'),
                  BottomNavItemData(icon: Icons.diversity_3, label: 'Gia đình'),
                  BottomNavItemData(
                      icon: Icons.receipt_long, label: 'Giao dịch'),
                  BottomNavItemData(
                      icon: Icons.person_outline, label: 'Người dùng'),
                ])),
          )),
    ));
    await tester.runAsync(() async {
      await precacheImage(const AssetImage('assets/images/logo.jpg'),
          tester.element(find.byType(OverviewTab)));
      await precacheImage(const AssetImage('assets/images/home_tab_art.png'),
          tester.element(find.byType(OverviewTab)));
    });
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_UI')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('overview-preview')));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/ui-review').create(recursive: true);
      await File('build/ui-review/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('Thiết kế mới dùng số thật, giữ chi tiết và so sánh kỳ trước',
      (tester) async {
    await open(tester);
    expect(find.text('Số dư hiện tại'), findsOneWidget);
    expect(find.text('61.830.000 đ'), findsOneWidget);
    expect(find.text('+48,5 triệu đ'), findsOneWidget);
    expect(find.text('−77,67 triệu đ'), findsOneWidget);
    expect(find.text('Thu – chi theo tuần'), findsOneWidget);
    expect(find.text('Phân bổ dòng tiền'), findsOneWidget);
    expect(find.text('Nhu cầu thiết yếu'), findsOneWidget);
    expect(find.byKey(const ValueKey('overview-amount-format')), findsNothing);
    final comparison = find.text('So sánh với kỳ trước');
    await tester.ensureVisible(comparison);
    await tester.tap(comparison);
    await tester.pumpAndSettle();
    expect(find.text('-29.170.000 đ'), findsOneWidget);
    expect(find.textContaining('+-'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await capture(tester, 'overview');
    final details = find.text('Xem chi tiết →').first;
    await tester.ensureVisible(details);
    await tester.tap(details);
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch trong kỳ'), findsOneWidget);
    expect(find.text('+48.500.000 đ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mở lịch và áp dụng khoảng ngày thực sự lọc báo cáo',
      (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('overview-date-range')));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    expect(find.text('Chọn khoảng thời gian'), findsOneWidget);
    await capture(tester, 'overview-calendar');
    // Hủy không đổi bộ lọc.
    Navigator.of(tester.element(find.byType(DateRangePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(find.text('+48,5 triệu đ'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('overview-date-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_calendar_outlined).last);
    await tester.pumpAndSettle();
    final localizations = MaterialLocalizations.of(
        tester.element(find.byType(DateRangePickerDialog)));
    final now = DateTime.now();
    final inputs = find.byType(TextField);
    await tester.enterText(inputs.at(0),
        localizations.formatCompactDate(DateTime(now.year, now.month - 1, 1)));
    await tester.enterText(inputs.at(1),
        localizations.formatCompactDate(DateTime(now.year, now.month, 0)));
    await tester.tap(find.text('Áp dụng').last);
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsNothing);
    expect(find.text('−1 nghìn đ'), findsOneWidget);
    expect(find.text('+48,5 triệu đ'), findsNothing);
    expect(find.text('61.830.000 đ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kỳ nhanh lọc đúng và chữ lớn không tràn', (tester) async {
    await open(tester, textScale: 1.3);
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await capture(tester, 'overview-large-text');
    await tester.tap(find.byTooltip('Đổi kỳ báo cáo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tháng này'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Đổi kỳ báo cáo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tháng trước'));
    await tester.pumpAndSettle();
    expect(find.text('−1 nghìn đ'), findsOneWidget);
    expect(find.text('+48,5 triệu đ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kỳ không có giao dịch có trạng thái rỗng', (tester) async {
    await open(tester, empty: true);
    expect(find.text('Chưa có giao dịch đã duyệt trong khoảng này.'),
        findsOneWidget);
    expect(find.text('+48,5 triệu đ'), findsNothing);
    expect(find.text('0 đ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hũ hiển thị tỷ lệ sử dụng và mở số đầy đủ', (tester) async {
    await open(tester);
    final jar = find.text('Nhu cầu thiết yếu');
    await tester.ensureVisible(jar);
    await tester.pumpAndSettle();
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('50%'), findsNothing);
    await capture(tester, 'overview-jars');
    await tester.tap(jar);
    await tester.pumpAndSettle();
    expect(find.text('Đã chi: 14.200.000 đ'), findsOneWidget);
    expect(find.text('Hạn mức: 22.000.000 đ'), findsOneWidget);
    expect(find.text('Tỷ trọng phân bổ: 50%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Đổi tổ ấm vẫn mở danh sách chọn', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Thay đổi tổ ấm'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListView, 'Chọn tổ ấm'), findsOneWidget);
    await tester.tap(find.text('Tổ ấm thứ hai'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byType(OverviewBalanceCard), matching: find.text('123 đ')),
        findsOneWidget);
    expect(find.text('+48,5 triệu đ'), findsNothing);
    expect(find.text('0 hũ chi tiêu · Số tiền rút gọn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chụp toàn bố cục mới để rà thiết kế', (tester) async {
    await open(tester);
    tester.view.physicalSize = const Size(390, 2100);
    await tester.pumpAndSettle();
    await capture(tester, 'overview-full');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hũ không hạn mức, vượt 150%, khoá và tên dài không tràn',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: SingleChildScrollView(
                child: OverviewJars(categories: const [
          FinancialCategoryModel(
              financialCategoryId: 1,
              name:
                  'Hũ có tên rất dài để kiểm tra khả năng xuống dòng trên điện thoại nhỏ',
              allocationPercent: 99,
              spent: 2000000000,
              limitAmount: 1000000000,
              status: CategoryStatus.locked),
          FinancialCategoryModel(
              financialCategoryId: 2,
              name: 'Chưa thiết lập',
              allocationPercent: 0,
              spent: 0,
              limitAmount: 0,
              status: CategoryStatus.active),
        ])))));
    await tester.pumpAndSettle();
    expect(find.text('200%'), findsOneWidget);
    expect(find.text('Đang khóa'), findsOneWidget);
    expect(find.text('Chưa có hạn mức'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
