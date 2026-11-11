import 'package:finance_management/api/voice_api.dart';
import 'package:finance_management/config/theme.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/models/voice_parse_result.dart';
import 'package:finance_management/providers/family_provider.dart';
import 'package:finance_management/providers/notification_provider.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:finance_management/providers/voice_capture_provider.dart';
import 'package:finance_management/screens/transaction/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeVoiceApi extends VoiceApi {
  _FakeVoiceApi({this.result, this.failure});

  final VoiceParseResult? result;
  final Object? failure;
  String? sentTranscript;
  int? sentFamilyId;

  @override
  Future<VoiceParseResult> parse(
      {required int familyId, required String transcript}) async {
    sentFamilyId = familyId;
    sentTranscript = transcript;
    if (failure != null) throw failure!;
    return result!;
  }
}

class _Families extends FamilyProvider {
  @override
  final List<FamilySummaryModel> families = [
    FamilySummaryModel(
      familyId: 1,
      code: 'TEST-1',
      name: 'Nhà 1',
      myRole: MemberRole.owner,
      totalBudget: 0,
      categoryCount: 1,
      members: const [],
    ),
  ];

  @override
  int get selectedFamilyId => 1;

  @override
  FamilyDetailModel? detail(int? familyId) => FamilyDetailModel(
        familyId: 1,
        code: 'TEST-1',
        name: 'Nhà 1',
        myRole: MemberRole.owner,
        totalBudget: 0,
        budgetGrowthPercent: 0,
        foundedLabel: '',
        members: const [],
        categories: const [],
        totalIncome: 0,
        totalExpense: 0,
        categoryActions: [CategoryAction(10, 'Ăn uống', false)],
      );
}

void main() {
  group('VoiceParseResult.fromJson', () {
    test('đọc đủ các trường Backend trả về', () {
      final r = VoiceParseResult.fromJson({
        'transactionType': 'INCOME',
        'amount': 15000000,
        'content': 'Lương',
        'financialCategoryId': 10,
        'categoryName': 'Ăn uống',
      });
      expect(r.type, TransactionType.income);
      expect(r.amount, 15000000);
      expect(r.content, 'Lương');
      expect(r.categoryId, 10);
    });

    test('trường null được giữ null, không đoán bừa', () {
      final r = VoiceParseResult.fromJson({
        'transactionType': 'EXPENSE',
        'amount': null,
        'content': null,
        'financialCategoryId': null,
        'categoryName': null,
      });
      expect(r.type, TransactionType.expense);
      expect(r.amount, isNull);
      expect(r.content, isNull);
      expect(r.categoryId, isNull);
    });
  });

  group('VoiceCaptureProvider.parse', () {
    test('gửi transcript đã cắt khoảng trắng và trả gợi ý', () async {
      final api = _FakeVoiceApi(
          result: const VoiceParseResult(
              type: TransactionType.expense, amount: 50000));
      final voice = VoiceCaptureProvider(api: api)
        ..editTranscript('  chi 50 nghìn cà phê  ');

      final result = await voice.parse(1);

      expect(result?.amount, 50000);
      expect(api.sentTranscript, 'chi 50 nghìn cà phê');
      expect(api.sentFamilyId, 1);
      expect(voice.parsing, isFalse);
      expect(voice.error, isNull);
    });

    test('transcript rỗng thì không gọi API', () async {
      final api = _FakeVoiceApi(
          result: const VoiceParseResult(type: TransactionType.expense));
      final voice = VoiceCaptureProvider(api: api)..editTranscript('   ');

      expect(voice.canParse, isFalse);
      expect(await voice.parse(1), isNull);
      expect(api.sentTranscript, isNull);
    });

    test('transcript quá dài bị chặn ở client', () async {
      final api = _FakeVoiceApi(
          result: const VoiceParseResult(type: TransactionType.expense));
      final voice = VoiceCaptureProvider(api: api)
        ..editTranscript('a' * (VoiceCaptureProvider.maxTranscriptLength + 1));

      expect(await voice.parse(1), isNull);
      expect(voice.error, isNotNull);
      expect(api.sentTranscript, isNull);
    });

    test('lỗi API được chuyển thành thông báo, không ném ra ngoài', () async {
      final voice = VoiceCaptureProvider(api: _FakeVoiceApi(failure: 'boom'))
        ..editTranscript('chi 50k');

      expect(await voice.parse(1), isNull);
      expect(voice.error, isNotNull);
      expect(voice.parsing, isFalse);
    });
  });

  testWidgets('form Nhập thủ công được điền sẵn từ gợi ý giọng nói',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<FamilyProvider>(create: (_) => _Families()),
        ChangeNotifierProvider<TransactionProvider>(
            create: (_) => TransactionProvider()),
        ChangeNotifierProvider<NotificationProvider>(
            create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const TransactionFormScreen(
          familyId: 1,
          prefill: VoiceParseResult(
            type: TransactionType.expense,
            amount: 50000,
            content: 'Cà phê',
            categoryId: 10,
            categoryName: 'Ăn uống',
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cà phê'), findsOneWidget);
    expect(find.text('50.000'), findsOneWidget);
    final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
    expect(chip.selected, isTrue);
  });
}
