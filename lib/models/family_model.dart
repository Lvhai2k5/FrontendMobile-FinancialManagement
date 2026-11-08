import '../utils/api_error.dart';

/// Vai trò của 1 Person trong 1 Family cụ thể — khớp `Relationship.memberRole`,
/// xem `BUSINESS-REQUIREMENTS.md` mục 4.3.
enum MemberRole { owner, member }

MemberRole memberRoleFromJson(String? value) =>
    value == 'OWNER' ? MemberRole.owner : MemberRole.member;

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
    this.permissions = const {},
  });

  final int personId;
  final String name;
  final MemberRole role;
  final Set<String> permissions;

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      FamilyMemberModel(
        personId: asInt(json['personId']),
        name: json['name'] as String? ?? '?',
        role: memberRoleFromJson(json['role'] as String?),
        permissions: ((json['permissions'] as List?) ?? const [])
            .whereType<String>()
            .toSet(),
      );

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
    this.canRead = true,
  });

  final int familyId;
  final String code;
  final String name;
  final MemberRole myRole;
  final double totalBudget;
  final int categoryCount;
  final bool canRead;
  final List<FamilyMemberModel> members;

  int get memberCount => members.length;

  factory FamilySummaryModel.fromJson(Map<String, dynamic> json) =>
      FamilySummaryModel(
        familyId: asInt(json['familyId']),
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        myRole: memberRoleFromJson(json['myRole'] as String?),
        totalBudget: asDouble(json['totalBudget']),
        categoryCount: asInt(json['categoryCount']),
        canRead: json['canRead'] != false,
        members: ((json['members'] as List?) ?? const [])
            .map((m) => FamilyMemberModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
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
    this.amountOfWarning = 0,
    this.amountOfEmergency = 0,
    this.amountOfApproval = 0,
  });

  final int financialCategoryId;
  final String name;
  final int allocationPercent;
  final double spent;
  final double limitAmount;
  final CategoryStatus status;
  final double amountOfWarning;
  final double amountOfEmergency;
  final double amountOfApproval;

  factory FinancialCategoryModel.fromJson(Map<String, dynamic> json) =>
      FinancialCategoryModel(
        financialCategoryId: asInt(json['financialCategoryId']),
        name: json['name'] as String? ?? '',
        allocationPercent: asInt(json['allocationPercent']),
        spent: asDouble(json['spent']),
        limitAmount: asDouble(json['limitAmount']),
        status: json['status'] == 'LOCKED'
            ? CategoryStatus.locked
            : CategoryStatus.active,
        amountOfWarning: asDouble(json['amountOfWarning']),
        amountOfEmergency: asDouble(json['amountOfEmergency']),
        amountOfApproval: asDouble(json['amountOfApproval']),
      );

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

class CategoryAction {
  const CategoryAction(this.id, this.name, this.locked);

  final int id;
  final String name;
  final bool locked;

  factory CategoryAction.fromJson(Map<String, dynamic> json) => CategoryAction(
        asInt(json['financialCategoryId']),
        json['name'] as String? ?? '',
        json['status'] == 'LOCKED',
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
    this.myPermissions = const {'READ', 'WRITE'},
    this.categoryActions = const [],
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
  final Set<String> myPermissions;
  final List<CategoryAction> categoryActions;

  bool get isOwner => myRole == MemberRole.owner;
  bool get canRead => isOwner || myPermissions.contains('READ');
  bool get canWrite => isOwner || myPermissions.contains('WRITE');
  bool get canApprove => isOwner || myPermissions.contains('APPROVAL');

  List<CategoryAction> get actionCategories => categoryActions.isNotEmpty
      ? categoryActions
      : categories
          .map((c) => CategoryAction(
              c.financialCategoryId, c.name, c.status == CategoryStatus.locked))
          .toList();

  factory FamilyDetailModel.fromJson(Map<String, dynamic> json) =>
      FamilyDetailModel(
        familyId: asInt(json['familyId']),
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        myRole: memberRoleFromJson(json['myRole'] as String?),
        totalBudget: asDouble(json['totalBudget']),
        budgetGrowthPercent: asDouble(json['budgetGrowthPercent']),
        foundedLabel: json['foundedLabel'] as String? ?? '',
        members: ((json['members'] as List?) ?? const [])
            .map((m) => FamilyMemberModel.fromJson(m as Map<String, dynamic>))
            .toList(),
        categories: ((json['categories'] as List?) ?? const [])
            .map((c) =>
                FinancialCategoryModel.fromJson(c as Map<String, dynamic>))
            .toList(),
        totalIncome: asDouble(json['totalIncome']),
        totalExpense: asDouble(json['totalExpense']),
        myPermissions: ((json['myPermissions'] as List?) ?? const [])
            .whereType<String>()
            .toSet(),
        categoryActions: ((json['categoryActions'] as List?) ?? const [])
            .map((c) => CategoryAction.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
