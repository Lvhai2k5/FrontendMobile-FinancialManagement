import 'package:finance_management/config/theme.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/providers/family_provider.dart';
import 'package:finance_management/providers/notification_provider.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:finance_management/screens/transaction/transaction_form_screen.dart';
import 'package:finance_management/widgets/common/inline_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Families extends FamilyProvider {
  _Families(this.families);

  @override
  final List<FamilySummaryModel> families;

  @override
  int get selectedFamilyId => families.first.familyId;

  @override
  FamilyDetailModel? detail(int? familyId) {
    for (final family in families) {
      if (family.familyId != familyId) continue;
      return FamilyDetailModel(
        familyId: family.familyId,
        code: family.code,
        name: family.name,
        myRole: family.myRole,
        totalBudget: 0,
        budgetGrowthPercent: 0,
        foundedLabel: '',
        members: const [],
        categories: const [],
        totalIncome: 0,
        totalExpense: 0,
        categoryActions: [
          CategoryAction(family.familyId * 10, 'Hũ ${family.familyId}', false),
        ],
      );
    }
    return null;
  }
}

class _Transactions extends TransactionProvider {
  int? submittedCategoryId;
  double? submittedAmount;

  @override
  Future<({TransactionModel? created, String? error, bool queued})>
      addManualTransaction({
    required int financialCategoryId,
    required String content,
    required double amount,
    required TransactionType type,
  }) async {
    submittedCategoryId = financialCategoryId;
    submittedAmount = amount;
    return (created: null, error: null, queued: true);
  }
}

FamilySummaryModel _family(int id) => FamilySummaryModel(
      familyId: id,
      code: 'TEST-$id',
      name: 'Nhà $id',
      myRole: MemberRole.owner,
      totalBudget: 0,
      categoryCount: 1,
      members: const [],
    );

Future<void> _open(WidgetTester tester, List<FamilySummaryModel> families,
    _Transactions transactions,
    {double width = 390, double scale = 1}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<FamilyProvider>(
          create: (_) => _Families(families)),
      ChangeNotifierProvider<TransactionProvider>(create: (_) => transactions),
      ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const TransactionFormScreen(),
            )),
            child: const Text('Mở form'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Mở form'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader(AppTypography.fontFamily);
    for (final weight in ['Regular', 'Medium', 'SemiBold']) {
      font.addFont(rootBundle
          .load('assets/fonts/be-vietnam-pro/BeVietnamPro-$weight.ttf'));
    }
    await font.load();
  });

  testWidgets('Hiện tên tổ ấm duy nhất và dùng thang chữ chung',
      (tester) async {
    await _open(tester, [_family(1)], _Transactions(), width: 320, scale: 1.3);

    expect(find.text('Tổ ấm'), findsOneWidget);
    expect(find.text('Nhà 1'), findsOneWidget);
    expect(find.text('Hũ 1'), findsOneWidget);
    final dropdown =
        tester.widget<InlinePicker<int>>(find.byType(InlinePicker<int>));
    expect(dropdown.value, 1);
    expect(dropdown.onChanged, isNotNull);
    final context = tester.element(find.text('Nhập thủ công'));
    final titleStyle = DefaultTextStyle.of(context).style;
    expect(titleStyle.fontFamily, AppTypography.fontFamily);
    expect(titleStyle.fontSize, AppTypography.headlineSm.fontSize);
    final labels = ['Tổ ấm', 'Nội dung', 'Số tiền', 'Danh mục'];
    for (final label in labels) {
      final style = tester.widget<Text>(find.text(label)).style;
      expect(style?.fontFamily, AppTypography.fontFamily);
      expect(style?.fontSize, AppTypography.titleSm.fontSize);
    }
  });

  testWidgets('Đổi tổ ấm bỏ hũ cũ và lưu theo hũ của tổ ấm mới',
      (tester) async {
    final transactions = _Transactions();
    await _open(tester, List.generate(12, (i) => _family(i + 1)), transactions);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Mua rau');
    await tester.enterText(fields.at(1), '10000');
    expect(
        tester.widget<TextFormField>(fields.at(1)).controller!.text, '10.000');
    await tester.tap(find.text('Hũ 1'));
    await tester.pumpAndSettle();
    expect(find.text('Nhà 2'), findsNothing);
    final inputY = tester.getTopLeft(fields.first).dy;
    final picker = find.byType(InlinePicker<int>);
    await tester.tap(find.descendant(of: picker, matching: find.text('Nhà 1')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(fields.first).dy, greaterThan(inputY));
    final menu = find.descendant(of: picker, matching: find.byType(Scrollable));
    await tester.drag(menu, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhà 12'));
    await tester.pumpAndSettle();

    expect(find.text('Nhà 12'), findsOneWidget);
    expect(find.text('Hũ 1'), findsNothing);
    final newCategory = find.widgetWithText(ChoiceChip, 'Hũ 12');
    expect(tester.widget<ChoiceChip>(newCategory).selected, isFalse);
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng chọn danh mục.'), findsOneWidget);
    expect(transactions.submittedCategoryId, isNull);

    await tester.tap(newCategory);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();
    expect(transactions.submittedCategoryId, 120);
    expect(transactions.submittedAmount, 10000);
  });
}
