import 'family_model.dart';
import 'transaction_model.dart';
import '../utils/api_error.dart';

class OverviewCategoryModel {
  const OverviewCategoryModel({
    required this.financialCategoryId,
    required this.name,
    required this.spent,
    required this.limitAmount,
    required this.usagePercent,
    required this.status,
  });

  final int financialCategoryId;
  final String name;
  final double spent;
  final double limitAmount;
  final double usagePercent;
  final CategoryStatus status;

  factory OverviewCategoryModel.fromJson(Map<String, dynamic> json) =>
      OverviewCategoryModel(
        financialCategoryId: asInt(json['financialCategoryId']),
        name: json['name'] as String? ?? '',
        spent: asDouble(json['spent']),
        limitAmount: asDouble(json['limitAmount']),
        usagePercent: asDouble(json['usagePercent']),
        status: json['status'] == 'LOCKED'
            ? CategoryStatus.locked
            : CategoryStatus.active,
      );

  FinancialCategoryModel toCategory() => FinancialCategoryModel(
        financialCategoryId: financialCategoryId,
        name: name,
        allocationPercent: 0,
        spent: spent,
        limitAmount: limitAmount,
        status: status,
      );
}

class OverviewModel {
  const OverviewModel({
    required this.familyId,
    required this.balance,
    required this.income,
    required this.expense,
    required this.categories,
    required this.recentTransactions,
  });

  final int familyId;
  final double balance;
  final double income;
  final double expense;
  final List<OverviewCategoryModel> categories;
  final List<TransactionModel> recentTransactions;

  factory OverviewModel.fromJson(Map<String, dynamic> json) => OverviewModel(
        familyId: asInt(json['familyId']),
        balance: asDouble(json['balance']),
        income: asDouble(json['income']),
        expense: asDouble(json['expense']),
        categories: ((json['categories'] as List?) ?? const [])
            .map((item) => OverviewCategoryModel.fromJson(
                item as Map<String, dynamic>))
            .toList(),
        recentTransactions: ((json['recentTransactions'] as List?) ?? const [])
            .map((item) =>
                TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
