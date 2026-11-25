import 'package:flutter_test/flutter_test.dart';
import 'package:finance_management/models/family_model.dart';
import 'package:finance_management/models/overview_model.dart';
import 'package:finance_management/utils/category_usage_status.dart';

void main() {
  test('parses API amounts, allocation share and warning thresholds', () {
    final overview = OverviewModel.fromJson({
      'familyId': 7,
      'balance': 8_500_000,
      'income': 2_000_000,
      'expense': 500_000,
      'categories': [
        {
          'financialCategoryId': 11,
          'name': 'Giáo dục',
          'spent': 6_500_000,
          'limitAmount': 10_000_000,
          'usagePercent': 65.0,
          'status': 'ACTIVE',
          'allocationPercent': 40,
          'amountOfWarning': 7_000_000,
          'amountOfEmergency': 9_000_000,
        },
      ],
      'recentTransactions': [],
    });

    final category = overview.categories.single.toCategory();
    expect(overview.balance, 8_500_000);
    expect(overview.income, 2_000_000);
    expect(overview.expense, 500_000);
    expect(category.allocationPercent, 40);
    expect(category.amountOfWarning, 7_000_000);
    expect(category.amountOfEmergency, 9_000_000);
    expect(categoryUsageStatus(category), CategoryUsageStatus.normal);
    expect(
        categoryUsageStatus(FinancialCategoryModel(
          financialCategoryId: category.financialCategoryId,
          name: category.name,
          allocationPercent: category.allocationPercent,
          spent: 7_000_000,
          limitAmount: category.limitAmount,
          status: category.status,
          amountOfWarning: category.amountOfWarning,
          amountOfEmergency: category.amountOfEmergency,
        )),
        CategoryUsageStatus.warning);
  });
}
