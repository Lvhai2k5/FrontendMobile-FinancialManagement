import 'package:flutter/foundation.dart';

import '../models/family_model.dart';

/// Logic + state cho nghiệp vụ Gia đình (`Family`/`Relationship`/
/// `FinancialCategory`/`Threshold`). Backend chưa có endpoint tương ứng nên
/// dữ liệu được seed sẵn tại đây thay vì gọi `api/` — giữ nguyên vai trò
/// "nơi duy nhất chứa logic nghiệp vụ thật phía client" của lớp `providers/`,
/// chỉ khác là chưa có HTTP call bên dưới. Khi Backend có API thật, thay
/// phần seed bằng gọi `FamilyApi` mà không cần đổi cách `screens/` dùng
/// provider này.
class FamilyProvider with ChangeNotifier {
  FamilyProvider() {
    _seed();
  }

  final List<FamilySummaryModel> _families = [];
  final Map<int, FamilyDetailModel> _details = {};
  final Map<int, List<ThresholdModel>> _thresholds = {};
  int _selectedFamilyId = 1;

  List<FamilySummaryModel> get families => List.unmodifiable(_families);

  int get selectedFamilyId => _selectedFamilyId;

  FamilySummaryModel get selectedFamily =>
      _families.firstWhere((f) => f.familyId == _selectedFamilyId);

  FamilyDetailModel detail(int familyId) => _details[familyId]!;

  List<ThresholdModel> thresholdsOf(int categoryId) =>
      List.unmodifiable(_thresholds[categoryId] ?? const []);

  void selectFamily(int familyId) {
    if (familyId == _selectedFamilyId) return;
    _selectedFamilyId = familyId;
    notifyListeners();
  }

  void updateThreshold(int categoryId, ThresholdType type,
      {double? amount, bool? enabled}) {
    final list = _thresholds[categoryId];
    if (list == null) return;
    final index = list.indexWhere((t) => t.type == type);
    if (index == -1) return;
    list[index] = list[index].copyWith(amount: amount, enabled: enabled);
    notifyListeners();
  }

  void _seed() {
    const minh = FamilyMemberModel(
        personId: 1, name: 'Nguyễn Văn Minh', role: MemberRole.owner);
    const lan = FamilyMemberModel(
        personId: 2, name: 'Trần Thị Thu Lan', role: MemberRole.member);
    const ngoc = FamilyMemberModel(
        personId: 3, name: 'Nguyễn Bảo Ngọc', role: MemberRole.member);
    const nguyen = FamilyMemberModel(
        personId: 4, name: 'Nguyễn Khôi Nguyên', role: MemberRole.member);

    final categories = [
      const FinancialCategoryModel(
        financialCategoryId: 101,
        name: 'Nhu cầu thiết yếu',
        allocationPercent: 55,
        spent: 14200000,
        limitAmount: 22000000,
        status: CategoryStatus.active,
      ),
      const FinancialCategoryModel(
        financialCategoryId: 102,
        name: 'Giáo dục & con cái',
        allocationPercent: 15,
        spent: 5800000,
        limitAmount: 8000000,
        status: CategoryStatus.active,
      ),
      const FinancialCategoryModel(
        financialCategoryId: 103,
        name: 'Tiết kiệm dài hạn',
        allocationPercent: 10,
        spent: 35000000,
        limitAmount: 40000000,
        status: CategoryStatus.active,
      ),
      const FinancialCategoryModel(
        financialCategoryId: 104,
        name: 'Hưởng thụ & giải trí',
        allocationPercent: 10,
        spent: 3100000,
        limitAmount: 4000000,
        status: CategoryStatus.active,
      ),
      const FinancialCategoryModel(
        financialCategoryId: 105,
        name: 'Quỹ khẩn cấp & y tế',
        allocationPercent: 5,
        spent: 15000000,
        limitAmount: 15000000,
        status: CategoryStatus.locked,
      ),
      const FinancialCategoryModel(
        financialCategoryId: 106,
        name: 'Cho đi & biếu tặng',
        allocationPercent: 5,
        spent: 1500000,
        limitAmount: 2000000,
        status: CategoryStatus.active,
      ),
    ];

    for (final category in categories) {
      _thresholds[category.financialCategoryId] = [
        const ThresholdModel(
            type: ThresholdType.approve, amount: 2000000, enabled: true),
        const ThresholdModel(
            type: ThresholdType.warning, amount: 15000000, enabled: true),
        const ThresholdModel(
            type: ThresholdType.emergency, amount: 3000000, enabled: false),
      ];
    }

    _families.addAll([
      FamilySummaryModel(
        familyId: 1,
        code: '#FN-204',
        name: 'Gia đình Minh & Lan',
        myRole: MemberRole.owner,
        totalBudget: 66400000,
        categoryCount: categories.length,
        members: [minh, lan, ngoc, nguyen],
      ),
      const FamilySummaryModel(
        familyId: 2,
        code: '#FN-108',
        name: 'Gia đình Bố Mẹ Nội',
        myRole: MemberRole.member,
        totalBudget: 28500000,
        categoryCount: 3,
        members: [
          FamilyMemberModel(
              personId: 5, name: 'Nguyễn Văn Bố', role: MemberRole.owner),
          FamilyMemberModel(
              personId: 6, name: 'Trần Thị Mẹ', role: MemberRole.member),
        ],
      ),
      const FamilySummaryModel(
        familyId: 3,
        code: '#FN-315',
        name: 'Gia đình Tiết Kiệm Anh Em',
        myRole: MemberRole.member,
        totalBudget: 45000000,
        categoryCount: 2,
        members: [
          FamilyMemberModel(
              personId: 7, name: 'Nguyễn Văn Anh', role: MemberRole.owner),
          FamilyMemberModel(
              personId: 8, name: 'Nguyễn Văn Em', role: MemberRole.member),
        ],
      ),
    ]);

    _details[1] = FamilyDetailModel(
      familyId: 1,
      code: '#FN-204',
      name: 'Gia đình Minh & Lan',
      myRole: MemberRole.owner,
      totalBudget: 66400000,
      budgetGrowthPercent: 12.5,
      foundedLabel: 'Thành lập 03/2023',
      members: [minh, lan, ngoc, nguyen],
      categories: categories,
      totalIncome: 48500000,
      totalExpense: 30080000,
    );

    for (final summary in _families.skip(1)) {
      final placeholderCategories = List.generate(
        summary.categoryCount,
        (i) => FinancialCategoryModel(
          financialCategoryId: 200 + summary.familyId * 10 + i,
          name: 'Danh mục ${i + 1}',
          allocationPercent: (100 / summary.categoryCount).round(),
          spent: summary.totalBudget * 0.4 / summary.categoryCount,
          limitAmount: summary.totalBudget / summary.categoryCount,
          status: CategoryStatus.active,
        ),
      );
      for (final category in placeholderCategories) {
        _thresholds[category.financialCategoryId] = [
          const ThresholdModel(
              type: ThresholdType.approve, amount: 2000000, enabled: true),
          const ThresholdModel(
              type: ThresholdType.warning, amount: 15000000, enabled: true),
          const ThresholdModel(
              type: ThresholdType.emergency, amount: 3000000, enabled: false),
        ];
      }
      _details[summary.familyId] = FamilyDetailModel(
        familyId: summary.familyId,
        code: summary.code,
        name: summary.name,
        myRole: summary.myRole,
        totalBudget: summary.totalBudget,
        budgetGrowthPercent: 0,
        foundedLabel: 'Thành lập 2023',
        members: summary.members,
        categories: placeholderCategories,
        totalIncome: summary.totalBudget * 0.7,
        totalExpense: summary.totalBudget * 0.45,
      );
    }
  }
}
