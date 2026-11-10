import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_management/config/theme.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/models/user_model.dart';
import 'package:finance_management/providers/auth_provider.dart';
import 'package:finance_management/providers/family_provider.dart';
import 'package:finance_management/providers/notification_provider.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:finance_management/providers/user_provider.dart';
import 'package:finance_management/routes/app_routes.dart';
import 'package:finance_management/screens/family/family_list_tab.dart';
import 'package:finance_management/screens/family/family_detail_screen.dart';
import 'package:finance_management/screens/home/home_shell_screen.dart';
import 'package:finance_management/screens/profile/edit_profile_screen.dart';
import 'package:finance_management/widgets/common/brand_wordmark.dart';
import 'package:finance_management/widgets/layout/home_app_bar.dart';
import 'package:finance_management/widgets/layout/bottom_nav_bar.dart';

FamilySummaryModel family(int id, {bool long = false}) => FamilySummaryModel(
        familyId: id,
        code: '#TEST-$id',
        name: long
            ? 'Tổ ấm có tên rất dài để kiểm tra cách hiển thị trên màn hình nhỏ $id'
            : 'Tổ ấm thử nghiệm $id',
        myRole: id == 1 ? MemberRole.owner : MemberRole.member,
        totalBudget: long ? 1234567890123 : 61830000,
        categoryCount: 6,
        members: const [
          FamilyMemberModel(
              personId: 1, name: 'Thành viên A', role: MemberRole.owner),
          FamilyMemberModel(
              personId: 2, name: 'Thành viên B', role: MemberRole.member)
        ]);

class Families extends FamilyProvider {
  Families(this.items);
  final List<FamilySummaryModel> items;
  int loads = 0;
  String? created;
  String? joined;
  FamilyDetailModel? previewDetail;
  Set<String>? savedPermissions;
  (int, bool)? lockChange;
  @override
  List<FamilySummaryModel> get families => items;
  @override
  int? get selectedFamilyId => items.isEmpty ? null : items.first.familyId;
  @override
  FamilyDetailModel? detail(int? id) =>
      previewDetail ??
      (items.isEmpty
          ? null
          : FamilyDetailModel(
              familyId: id!,
              code: '',
              name: items.first.name,
              myRole: MemberRole.owner,
              totalBudget: 61830000,
              budgetGrowthPercent: 0,
              foundedLabel: '',
              members: const [],
              categories: const [],
              totalIncome: 0,
              totalExpense: 0));

  @override
  Future<String?> updatePermissions(
      int familyId, int personId, Set<String> permissions) async {
    savedPermissions = permissions;
    return null;
  }

  @override
  Future<String?> setCategoryLocked(int categoryId, bool locked) async {
    lockChange = (categoryId, locked);
    return null;
  }

  @override
  Future<void> load() async {
    loads++;
  }

  @override
  Future<({int? familyId, String? error})> createFamily(String name) async {
    created = name;
    return (familyId: 99, error: null);
  }

  @override
  Future<String?> joinFamily(String code) async {
    joined = code;
    return null;
  }
}

class Transactions extends TransactionProvider {
  final entries = <TransactionModel>[];
  @override
  List<TransactionModel> get transactions => entries;

  int loads = 0;
  @override
  Future<void> load() async {
    loads++;
  }
}

class Notifications extends NotificationProvider {
  @override
  Future<void> load() async {}
}

class User extends UserProvider {
  ({String name, String phone, String email})? saved;

  @override
  Future<void> load() async {}

  @override
  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    saved = (name: name, phone: phone, email: email);
    return null;
  }
}

class Session extends AuthProvider {
  bool loggedOut = false;

  @override
  Future<void> logout() async {
    loggedOut = true;
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

  testWidgets('Hồ sơ kiểm tra dữ liệu và ở lại màn chỉnh sửa sau khi lưu',
      (tester) async {
    final user = User()
      ..user = const UserModel(
        personId: 1,
        username: 'test-user',
        name: 'Nguyễn An',
        email: 'an@example.com',
        phone: '0912345678',
        role: 'USER',
      );
    await tester.pumpWidget(ChangeNotifierProvider<UserProvider>(
      create: (_) => user,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(),
              )),
              child: const Text('Mở hồ sơ'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Mở hồ sơ'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    final save = find.text('Lưu thay đổi');
    expect(fields, findsNWidgets(3));
    expect(find.text('Ngày sinh'), findsNothing);
    expect(find.text('Họ và tên (*)'), findsOneWidget);
    expect(find.text('Bắt buộc (*)'), findsNothing);
    expect(find.textContaining('qua email.'), findsNothing);
    await tester.enterText(fields.at(0), 'An 123');
    await tester.enterText(fields.at(1), '123');
    await tester.enterText(fields.at(2), 'an@other.example');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(user.saved, isNull);
    expect(find.textContaining('Nhập họ tên bằng chữ'), findsOneWidget);
    expect(find.textContaining('Số điện thoại cần đúng'), findsOneWidget);
    expect(find.textContaining('kết thúc bằng @gmail.com'), findsOneWidget);

    await tester.enterText(fields.at(0), 'Nguyễn An');
    await tester.enterText(fields.at(1), '+84 912 345 678');
    await tester.enterText(fields.at(2), 'an@example.com');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(user.saved?.email, 'an@example.com');
    await tester.enterText(fields.at(2), 'an@gmail.com');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(user.saved,
        (name: 'Nguyễn An', phone: '0912345678', email: 'an@gmail.com'));
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Đã lưu thay đổi.'), findsOneWidget);
  });

  Future<Transactions> open(WidgetTester tester, Families families,
      {bool shell = false,
      double scale = 1,
      double width = 390,
      Session? session,
      bool realDetail = false}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final transactions = Transactions();
    await tester.pumpWidget(RepaintBoundary(
        key: const ValueKey('family-preview'),
        child: MultiProvider(
            providers: [
              if (session != null)
                ChangeNotifierProvider<AuthProvider>.value(value: session),
              ChangeNotifierProvider<FamilyProvider>.value(value: families),
              ChangeNotifierProvider<TransactionProvider>.value(
                  value: transactions),
              ChangeNotifierProvider<NotificationProvider>(
                  create: (_) => Notifications()),
              ChangeNotifierProvider<UserProvider>(create: (_) => User()),
            ],
            child: MaterialApp(
                theme: AppTheme.light,
                debugShowCheckedModeBanner: false,
                initialRoute: AppRoutes.home,
                routes: {
                  AppRoutes.home: (_) => shell
                      ? const HomeShellScreen()
                      : const Scaffold(
                          appBar: HomeAppBar(emphasizeBrand: true),
                          body: FamilyListTab()),
                  AppRoutes.transactionForm: (context) => Scaffold(
                      body: Text(
                          'Nhập cho tổ ấm ${ModalRoute.of(context)!.settings.arguments}')),
                  AppRoutes.supportFeedback: (_) =>
                      const Scaffold(body: Text('Biểu mẫu hỗ trợ')),
                  AppRoutes.forgotPassword: (_) =>
                      const Scaffold(body: Text('Luồng mật khẩu')),
                  AppRoutes.notifications: (_) =>
                      const Scaffold(body: Text('Danh sách thông báo')),
                  AppRoutes.welcome: (_) =>
                      const Scaffold(body: Text('Màn chào sau đăng xuất')),
                  AppRoutes.familyDetail: (context) {
                    final id =
                        ModalRoute.of(context)!.settings.arguments as int;
                    return realDetail
                        ? FamilyDetailScreen(familyId: id)
                        : Scaffold(body: Text('Chi tiết $id'));
                  }
                }))));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomeAppBar));
      await precacheImage(const AssetImage('assets/images/logo.jpg'), context);
      await precacheImage(
          const AssetImage('assets/images/home_tab_art.png'), context);
    });
    await tester.pumpAndSettle();
    return transactions;
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_UI')) return;
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('family-preview')));
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/ui-review').create(recursive: true);
      await File('build/ui-review/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  FamilyDetailModel detailFor(MemberRole role, Set<String> permissions) =>
      FamilyDetailModel(
        familyId: 1,
        code: role == MemberRole.owner ? '#FN-1-mamoi' : '',
        name: 'Tổ ấm thử nghiệm 1',
        myRole: role,
        totalBudget: 1200000,
        budgetGrowthPercent: 0,
        foundedLabel: '',
        members: family(1).members,
        categories: const [],
        totalIncome: 0,
        totalExpense: 0,
        myPermissions: permissions,
        categoryActions: const [CategoryAction(7, 'Ăn uống', true)],
      );

  testWidgets('Chủ hộ cấp quyền Duyệt từ menu thành viên ở màn nhỏ',
      (tester) async {
    final families = Families([family(1)])
      ..previewDetail = detailFor(MemberRole.owner, const {});
    await open(tester, families, realDetail: true, width: 320, scale: 1.3);
    await tester.tap(find.text('Tổ ấm thử nghiệm 1'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm thành viên'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Quản lý Thành viên B'));
    await tester.tap(find.byTooltip('Quản lý Thành viên B'));
    await tester.pumpAndSettle();
    expect(find.text('Chuyển vai trò Chủ hộ'), findsOneWidget);
    expect(find.text('Xóa thành viên'), findsOneWidget);
    await tester.tap(find.text('Chỉnh quyền'));
    await tester.pumpAndSettle();
    await capture(tester, 'family-permissions');
    await tester.tap(find.text('Duyệt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu quyền'));
    await tester.pumpAndSettle();
    expect(families.savedPermissions, {'APPROVAL'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('Thành viên có Duyệt mở khóa được mà không thấy số dư',
      (tester) async {
    final families = Families([family(1)])
      ..previewDetail = detailFor(MemberRole.member, const {'APPROVAL'});
    await open(tester, families, realDetail: true);
    await tester.tap(find.text('Tổ ấm thử nghiệm 1'));
    await tester.pumpAndSettle();
    expect(find.text('TỔNG QUỸ CHUNG KHẢ DỤNG'), findsNothing);
    expect(find.text('Thêm thành viên'), findsNothing);
    expect(find.text('Thêm giao dịch'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Mở khóa Ăn uống'));
    await capture(tester, 'family-delegated-unlock');
    await tester.tap(find.byTooltip('Mở khóa Ăn uống'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Mở khóa danh mục'));
    await tester.pumpAndSettle();
    expect(families.lockChange, (7, false));
  });

  testWidgets('Nhiều gia đình giữ quỹ/vai trò riêng, cuộn và mở đúng ID',
      (tester) async {
    await open(tester, Families(List.generate(30, (i) => family(i + 1))));
    expect(find.text('Đang tham gia 30 gia đình'), findsOneWidget);
    expect(find.text('Chủ hộ 1'), findsOneWidget);
    expect(find.text('Thành viên 29'), findsOneWidget);
    expect(find.text('Tổ ấm thử nghiệm 30'), findsNothing);
    await capture(tester, 'family-multiple');
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('family-card-30')), 500,
        scrollable: find.byType(Scrollable).first, maxScrolls: 40);
    await tester.tap(find.text('Tổ ấm thử nghiệm 30'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết 30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Một gia đình: bố cục gọn và số tiền đầy đủ', (tester) async {
    await open(tester, Families([family(1)]));
    expect(find.text('61.830.000 đ'), findsOneWidget);
    expect(find.text('6 danh mục tài chính'), findsOneWidget);
    expect(find.text('2 thành viên'), findsOneWidget);
    await capture(tester, 'family-single');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tên dài, quỹ lớn, màn 320px chữ 130% không tràn',
      (tester) async {
    await open(tester, Families([family(1, long: true), family(2)]),
        scale: 1.3, width: 320);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('family-card-1')), 200,
        scrollable: find.byType(Scrollable).first);
    await capture(tester, 'family-large-text');
    expect(find.text('1.234.567.890.123 đ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tạo và tham gia vẫn gọi hành động hiện có', (tester) async {
    final families = Families([]);
    final transactions = await open(tester, families);
    await tester.tap(find.text('Tạo gia đình mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tổ ấm mới');
    await tester.tap(find.text('Tạo gia đình'));
    await tester.pumpAndSettle();
    expect(families.created, 'Tổ ấm mới');
    final detail = find.text('Chi tiết 99');
    expect(detail, findsOneWidget);
    Navigator.of(tester.element(detail)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nhập mã mời'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#TEST-2');
    await tester.tap(find.text('Gia nhập'));
    await tester.pumpAndSettle();
    expect(families.joined, '#TEST-2');
    expect(transactions.loads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rỗng và kéo để tải lại giữ hoạt động', (tester) async {
    final families = Families([]);
    await open(tester, families);
    expect(
        find.textContaining('Bạn chưa tham gia gia đình nào.'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(families.loads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Chuyển Tổng quan sang Gia đình giữ logo, chiều cao header và cỡ tiêu đề',
      (tester) async {
    await open(tester, Families([family(1)]), shell: true);
    final before = tester.getSize(find.byType(HomeAppBar));
    final overview = tester.widget<Text>(find.text('Tổng quan').first).style!;
    final brand = tester.widget<BrandWordmark>(find.byType(BrandWordmark));
    await tester.tap(find.descendant(
        of: find.byType(BottomNavBar), matching: find.text('Gia đình')));
    await tester.pumpAndSettle();
    final title = tester.widget<Text>(find.text('Gia đình').first).style!;
    expect(title.fontSize, 24);
    expect(title, overview);
    expect(tester.getSize(find.byType(HomeAppBar)), before);
    final after = tester.widget<BrandWordmark>(find.byType(BrandWordmark));
    expect(after.fontSize, brand.fontSize);
    expect(after.logoSize, brand.logoSize);
    final wordmark = tester.widget<Text>(find.descendant(
      of: find.byType(BrandWordmark),
      matching: find.byType(Text),
    ));
    final spans = wordmark.textSpan! as TextSpan;
    expect(spans.style?.color, Colors.black);
    expect(spans.children!.single.style?.color, const Color(0xFFC45D25));
    await capture(tester, 'family-tab');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Giao dịch giữ bốn phương thức và nối tìm kiếm với bộ lọc',
      (tester) async {
    final transactions = await open(tester, Families([family(1)]),
        shell: true, width: 320, scale: 1.3);
    final now = DateTime.now();
    transactions.entries.addAll([
      TransactionModel(
          transactionId: 1,
          content: 'Mua sách',
          amount: 50000,
          type: TransactionType.expense,
          status: TransactionStatus.pend,
          categoryName: 'Giáo dục',
          createdAt: now),
      TransactionModel(
          transactionId: 2,
          content: 'Đi chợ',
          amount: 100000,
          type: TransactionType.expense,
          status: TransactionStatus.approve,
          categoryName: 'Thiết yếu',
          createdAt: now.subtract(const Duration(days: 12))),
      TransactionModel(
          transactionId: 3,
          content: 'Hoàn tiền',
          amount: 5000,
          type: TransactionType.income,
          status: TransactionStatus.approve,
          categoryName: 'Thiết yếu',
          createdAt: now.subtract(const Duration(days: 12))),
    ]);
    await tester.tap(find.descendant(
        of: find.byType(BottomNavBar), matching: find.text('Giao dịch')));
    await tester.pumpAndSettle();
    for (final name in ['Quét hoá đơn', 'Ghi âm giọng nói', 'Quét đồ vật']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.textContaining('sẽ có ở bản cập nhật tiếp theo'),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }
    await capture(tester, 'transactions-tab');
    await tester.tap(find.text('Nhập thủ công'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập cho tổ ấm 1'), findsOneWidget);
    Navigator.of(tester.element(find.text('Nhập cho tổ ấm 1'))).pop();
    await tester.pumpAndSettle();
    final search = find.byType(TextField);
    await tester.ensureVisible(search);
    await tester.enterText(search, 'thiết yếu');
    await tester.pumpAndSettle();
    expect(find.text('Đi chợ'), findsOneWidget);
    expect(find.text('Mua sách'), findsNothing);
    final today = find.text('Hôm nay');
    await tester.ensureVisible(today);
    await tester.tap(today);
    await tester.pumpAndSettle();
    expect(find.text('Đi chợ'), findsNothing);
    await tester.enterText(search, '');
    await tester.pumpAndSettle();
    expect(find.text('Mua sách'), findsOneWidget);
    expect(find.text('Chờ duyệt'), findsOneWidget);

    final tune = find.byTooltip('Tùy biến tìm kiếm giao dịch');
    await tester.ensureVisible(tune);
    await tester.tap(tune);
    await tester.pumpAndSettle();
    await capture(tester, 'transaction-search-options');
    await tester.tap(find.text('Chọn khoảng ngày'));
    await tester.pumpAndSettle();
    final datePicker = find.byType(DateRangePickerDialog);
    final popup = tester.getRect(datePicker);
    expect(popup.height, lessThan(560));
    expect(popup.left, greaterThan(0));
    final popupTitle = find.descendant(
        of: datePicker, matching: find.text('Chọn khoảng ngày'));
    expect(tester.renderObject<RenderParagraph>(popupTitle).didExceedMaxLines,
        isFalse);
    await capture(tester, 'transaction-date-popup');
    await tester.tap(find.byIcon(Icons.edit_calendar_outlined));
    await tester.pumpAndSettle();
    final date = MaterialLocalizations.of(tester.element(datePicker))
        .formatCompactDate(now.subtract(const Duration(days: 12)));
    final dateFields =
        find.descendant(of: datePicker, matching: find.byType(TextField));
    await tester.enterText(dateFields.at(0), date);
    await tester.enterText(dateFields.at(1), date);
    await tester.tap(find.text('Chọn khoảng này').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Chi tiêu'));
    await tester.tap(find.text('Áp dụng bộ lọc'));
    await tester.pumpAndSettle();
    expect(find.text('Đi chợ'), findsOneWidget);
    expect(find.text('Hoàn tiền'), findsNothing);
    expect(find.text('Mua sách'), findsNothing);
    expect(find.widgetWithText(InputChip, 'Chi tiêu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Người dùng giữ hồ sơ, đúng tổ ấm và hỗ trợ', (tester) async {
    final session = Session();
    await open(tester, Families([family(1), family(2)]),
        shell: true, session: session);
    await tester.tap(find.descendant(
        of: find.byType(BottomNavBar), matching: find.text('Người dùng')));
    await tester.pumpAndSettle();
    await capture(tester, 'profile-tab');
    expect(find.text('Cấu hình danh mục tài chính'), findsNothing);
    expect(find.text('Cấu hình gia đình'), findsNothing);
    expect(find.text('Bạn và những tổ ấm của mình'), findsNothing);
    await tester.tap(find.text('Chỉnh sửa thông tin cá nhân'));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(tester.getBottomLeft(find.text('Hủy bỏ')).dy,
        lessThan(tester.getTopLeft(find.byType(BottomNavBar)).dy));
    await capture(tester, 'profile-edit-tab');
    await tester.tap(find.descendant(
        of: find.byType(BottomNavBar), matching: find.text('Gia đình')));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsNothing);
    await tester.tap(find.descendant(
        of: find.byType(BottomNavBar), matching: find.text('Người dùng')));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Chỉnh sửa thông tin cá nhân'), findsOneWidget);
    for (final (label, destination) in [
      ('Tổ ấm thử nghiệm 2', 'Chi tiết 2'),
      ('Thay đổi mật khẩu', 'Luồng mật khẩu'),
      ('Gửi thông tin cần hỗ trợ', 'Biểu mẫu hỗ trợ'),
    ]) {
      final action = find.text(label);
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text(destination), findsOneWidget);
      Navigator.of(tester.element(find.text(destination))).pop();
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byIcon(Icons.notifications_none));
    await tester.pumpAndSettle();
    final notifications = find.text('Danh sách thông báo');
    expect(notifications, findsOneWidget);
    Navigator.of(tester.element(notifications)).pop();
    await tester.pumpAndSettle();
    final logout = find.text('Đăng xuất tài khoản');
    await tester.ensureVisible(logout);
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(session.loggedOut, isTrue);
    final welcome = find.text('Màn chào sau đăng xuất');
    expect(welcome, findsOneWidget);
    expect(Navigator.of(tester.element(welcome)).canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });
}
