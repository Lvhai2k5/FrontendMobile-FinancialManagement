import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../utils/format_currency.dart';
import '../../widgets/family/category_progress_tile.dart';
import '../../widgets/family/customize_report_sheet.dart';

enum _Period { lastMonth, lastYear, custom }

/// Tab "Tổng quan" — trang chủ báo cáo thu/chi + phân bổ 6 hũ tài chính của
/// gia đình đang chọn. Thiết kế theo `finnest_tab_t_ng_quan`.
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  _Period _period = _Period.lastMonth;

  void _openCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomizeReportSheet(),
    );
  }

  void _openFamilyPicker(FamilyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Chọn tổ ấm', style: AppTypography.titleSm),
            const SizedBox(height: 8),
            for (final family in provider.families)
              ListTile(
                leading: const Icon(Icons.home_outlined,
                    color: AppColors.primary),
                title: Text(family.name),
                subtitle: Text('${family.code} · ${family.memberCount} thành viên'),
                trailing: family.familyId == provider.selectedFamilyId
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.selectFamily(family.familyId);
                  Navigator.of(context).pop();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = context.watch<FamilyProvider>();
    final family = familyProvider.detail(familyProvider.selectedFamilyId);
    final net = family.totalIncome - family.totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FamilySwitcherCard(
            familyName: family.name,
            onChange: () => _openFamilyPicker(familyProvider),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng quan', style: AppTypography.headlineSm),
              _PeriodTabs(
                period: _period,
                onSelect: (p) {
                  if (p == _Period.custom) {
                    _openCustomizeSheet();
                  } else {
                    setState(() => _period = p);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Khoảng thời gian: ${_periodRangeLabel()}',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _RemainingCard(family: family),
          const SizedBox(height: 20),
          Text('Báo cáo thu - chi', style: AppTypography.headlineSm),
          const SizedBox(height: 12),
          _ReportComparisonCard(income: family.totalIncome, expense: family.totalExpense, net: net),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cơ cấu phân bổ dòng tiền', style: AppTypography.headlineSm),
              Text('${family.categories.length} hũ chi tiêu',
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 12),
          for (final category in family.categories)
            CategoryProgressTile(category: category),
          const SizedBox(height: 8),
          Text('Đánh giá & dự đoán tài chính gia đình',
              style: AppTypography.headlineSm),
          const SizedBox(height: 12),
          const _ForecastCard(),
        ],
      ),
    );
  }

  String _periodRangeLabel() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(start.day)}/${two(start.month)}/${start.year} – ${two(now.day)}/${two(now.month)}/${now.year}';
  }
}

class _FamilySwitcherCard extends StatelessWidget {
  const _FamilySwitcherCard({required this.familyName, required this.onChange});

  final String familyName;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.pastelBlush,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.home_outlined, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tổ ấm đang quản lý',
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                Text(familyName, style: AppTypography.titleSm),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onChange,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: BorderSide(color: AppColors.surfaceContainer),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.unfold_more, size: 16),
            label: const Text('Thay đổi'),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.period, required this.onSelect});

  final _Period period;
  final ValueChanged<_Period> onSelect;

  @override
  Widget build(BuildContext context) {
    Widget chip(_Period value, String label, IconData? icon) {
      final selected = period == value;
      return GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: selected ? Colors.white : AppColors.outline),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: AppTypography.labelSm.copyWith(
                      color: selected ? Colors.white : AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(_Period.lastMonth, 'Tháng trước', null),
        chip(_Period.lastYear, 'Năm trước', null),
        chip(_Period.custom, 'Tùy biến', Icons.tune),
      ],
    );
  }
}

class _RemainingCard extends StatelessWidget {
  const _RemainingCard({required this.family});

  final FamilyDetailModel family;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: AppColors.outline),
              const SizedBox(width: 6),
              Text('Tổng tiền còn lại',
                  style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('+${family.budgetGrowthPercent}% so với kỳ trước',
                    style: AppTypography.labelSm.copyWith(color: AppColors.secondary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${formatCurrency(family.totalBudget)} đ',
              style: AppTypography.brandTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                    label: 'Tổng thu trong kỳ',
                    value: family.totalIncome,
                    icon: Icons.south_west,
                    color: AppColors.secondary),
              ),
              Expanded(
                child: _MiniStat(
                    label: 'Tổng chi trong kỳ',
                    value: family.totalExpense,
                    icon: Icons.north_east,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text('${formatCurrency(value)} đ', style: AppTypography.titleSm.copyWith(color: color)),
          ],
        ),
      ],
    );
  }
}

class _ReportComparisonCard extends StatelessWidget {
  const _ReportComparisonCard(
      {required this.income, required this.expense, required this.net});

  final double income;
  final double expense;
  final double net;

  @override
  Widget build(BuildContext context) {
    final maxValue = income > expense ? income : expense;
    double ratio(double v) => maxValue == 0 ? 0 : (v / maxValue).clamp(0.05, 1.0);

    Widget bar(String label, double incomeVal, double expenseVal, bool highlight) {
      return Expanded(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 10,
                    height: 64 * ratio(incomeVal),
                    decoration: BoxDecoration(
                      color: highlight ? AppColors.primary : AppColors.pastelBlush,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 10,
                    height: 64 * ratio(expenseVal),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: AppTypography.labelSm.copyWith(
                    color: highlight ? AppColors.primary : AppColors.outline)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: AppColors.primary, label: 'Thu nhập: ${_shortAmount(income)}'),
              const SizedBox(width: 12),
              _LegendDot(
                  color: AppColors.secondaryContainer,
                  label: 'Chi tiêu: ${_shortAmount(expense)}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              bar('Kỳ trước nữa', income * 0.8, expense * 0.9, false),
              bar('Kỳ liền trước', income * 0.9, expense * 0.95, false),
              bar('Kỳ hiện tại', income, expense, true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Chênh lệch thặng dư: ',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
              Text('+${formatCurrency(net)} đ',
                  style: AppTypography.labelMd.copyWith(color: AppColors.secondary)),
            ],
          ),
        ],
      ),
    );
  }

  String _shortAmount(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    return formatCurrency(value);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tốc độ chi tiêu hiện tại',
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                    const SizedBox(height: 4),
                    Text('970.000 đ/ngày', style: AppTypography.titleSm),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('Trong giới hạn an toàn',
                            style: AppTypography.labelSm.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dự đoán số dư cuối kỳ',
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                    const SizedBox(height: 4),
                    Text('+17.850.000 đ',
                        style: AppTypography.titleSm.copyWith(color: AppColors.secondary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('Vượt 8.2% kế hoạch',
                            style: AppTypography.labelSm.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Khuyến nghị từ trợ lý FinNest: hũ giáo dục & con cái đang đạt hơn 70% định mức. Nên cân đối các khoản mua sắm sách và thiết bị ngoại khoá sang kỳ tới để bảo toàn thặng dư mục tiêu.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
