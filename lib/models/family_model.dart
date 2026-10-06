/// Vai trò của 1 Person trong 1 Family cụ thể — khớp `Relationship.memberRole`,
/// xem `BUSINESS-REQUIREMENTS.md` mục 4.3.
enum MemberRole { owner, member }

extension MemberRoleLabel on MemberRole {
  String get label => this == MemberRole.owner ? 'Chủ hộ' : 'Thành viên';
}

/// 1 thành viên trong danh sách "Thành viên" của 1 Family — dữ liệu rút gọn
/// từ `Person` + `Relationship`, đủ cho hiển thị (không phải DTO thật vì
/// Backend chưa có endpoint `/families`).
class FamilyMemberModel {
  const FamilyMemberModel({
    required this.personId,
    required this.name,
    required this.role,
  });

  final int personId;
  final String name;
  final MemberRole role;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.last.isEmpty) return '?';
    return parts.last.substring(0, 1).toUpperCase();
  }
}

/// 1 dòng trong danh sách "Danh sách gia đình" (tab Gia đình) — tương ứng
/// `Family` + số liệu tổng hợp từ `FinancialCategory`/`Relationship`.
class FamilySummaryModel {
  const FamilySummaryModel({
    required this.familyId,
    required this.code,
    required this.name,
    required this.myRole,
    required this.totalBudget,
    required this.categoryCount,
    required this.members,
  });

  final int familyId;
  final String code;
  final String name;
  final MemberRole myRole;
  final double totalBudget;
  final int categoryCount;
  final List<FamilyMemberModel> members;

  int get memberCount => members.length;
}

/// Trạng thái của 1 `FinancialCategory` — khớp `CategoryStatus`.
enum CategoryStatus { active, locked }

/// 1 "hũ chi tiêu" — khớp entity `FinancialCategory`, xem mục 4.5.
class FinancialCategoryModel {
  const FinancialCategoryModel({
    required this.financialCategoryId,
    required this.name,
    required this.allocationPercent,
    required this.spent,
    required this.limitAmount,
    required this.status,
  });

  final int financialCategoryId;
  final String name;
  final int allocationPercent;
  final double spent;
  final double limitAmount;
  final CategoryStatus status;

  double get usageRatio =>
      limitAmount <= 0 ? 0 : (spent / limitAmount).clamp(0, 1.5);
}

/// Loại ngưỡng kiểm soát chi tiêu — khớp `ThresholdType`, mục 3.3/5.
enum ThresholdType { approve, warning, emergency }

/// 1 ngưỡng của 1 `FinancialCategory` — khớp entity `Threshold`, mục 4.6.
class ThresholdModel {
  const ThresholdModel({
    required this.type,
    required this.amount,
    required this.enabled,
  });

  final ThresholdType type;
  final double amount;
  final bool enabled;

  ThresholdModel copyWith({double? amount, bool? enabled}) => ThresholdModel(
        type: type,
        amount: amount ?? this.amount,
        enabled: enabled ?? this.enabled,
      );
}

/// Chi tiết đầy đủ 1 Family — dùng cho màn "Chi tiết gia đình".
class FamilyDetailModel {
  const FamilyDetailModel({
    required this.familyId,
    required this.code,
    required this.name,
    required this.myRole,
    required this.totalBudget,
    required this.budgetGrowthPercent,
    required this.foundedLabel,
    required this.members,
    required this.categories,
    required this.totalIncome,
    required this.totalExpense,
  });

  final int familyId;
  final String code;
  final String name;
  final MemberRole myRole;
  final double totalBudget;
  final double budgetGrowthPercent;
  final String foundedLabel;
  final List<FamilyMemberModel> members;
  final List<FinancialCategoryModel> categories;

  /// Tổng thu/chi trong kỳ đang xem — dùng cho tab "Tổng quan". Số liệu mock
  /// (Backend chưa có endpoint tổng hợp báo cáo theo kỳ).
  final double totalIncome;
  final double totalExpense;
}
