import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../widgets/common/compact_date_range_dialog.dart';
import '../../widgets/common/inline_picker.dart';
import '../../widgets/layout/home_tab_header.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/format_currency.dart';
import '../../utils/overview_summary.dart';
import 'overview_dashboard.dart';
import '../family/family_actions.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  OverviewPeriod _period = OverviewPeriod.thisMonth;
  late DateTimeRange _range = overviewPeriodRange(_period, DateTime.now());

  String _dateLabel() {
    String date(DateTime value) =>
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
    return '${date(_range.start)} – ${date(_range.end)}';
  }

  Future<void> _pickDates() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: 'Chọn khoảng thời gian',
      saveText: 'Áp dụng',
      confirmText: 'Áp dụng',
      cancelText: 'Hủy',
      switchToInputEntryModeIcon: const Icon(Icons.edit_calendar_outlined),
      builder: compactDateRangeDialog,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _range = picked;
      _period = OverviewPeriod.custom;
    });
  }

  void _showTransactions(OverviewSummary summary) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text('Giao dịch trong kỳ', style: AppTypography.headlineSm),
            const SizedBox(height: 8),
            Text(_dateLabel(), style: AppTypography.bodySm),
            if (summary.transactions.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('Chưa có giao dịch đã duyệt trong khoảng này.')),
            for (final transaction in summary.transactions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(transaction.content),
                subtitle: Text(
                    '${transaction.createdAt.toLocal().day}/${transaction.createdAt.toLocal().month}/${transaction.createdAt.toLocal().year}'),
                trailing: Text(
                    '${transaction.type == TransactionType.income ? '+' : '−'}${formatCurrency(transaction.amount)} đ',
                    style: AppTypography.labelMd.copyWith(
                        color: transaction.type == TransactionType.income
                            ? AppColors.secondary
                            : AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<FamilyProvider>();
    final family = families.detail(families.selectedFamilyId);
    if (family == null) return _EmptyOverview(loading: families.loading);
    final transactions = context.watch<TransactionProvider>();
    final summary =
        OverviewSummary(transactions.transactions, family.familyId, _range);
    DateTimeRange before(DateTimeRange range) {
      final end = range.start.subtract(const Duration(days: 1));
      return DateTimeRange(
          start: end.subtract(Duration(days: range.duration.inDays)), end: end);
    }

    final previousRange = before(_range);
    final previous = OverviewSummary(
        transactions.transactions, family.familyId, previousRange);
    final earlier = OverviewSummary(
        transactions.transactions, family.familyId, before(previousRange));
    final month = OverviewSummary(transactions.transactions, family.familyId,
        overviewPeriodRange(OverviewPeriod.thisMonth, DateTime.now()));
    return RefreshIndicator(
      onRefresh: () => Future.wait([families.load(), transactions.load()]),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HomeTabHeader(
              title: 'Tổng quan',
              artwork: HomeTabArtwork.overview,
              icon: Icons.home_outlined),
          Tooltip(
            message: 'Thay đổi tổ ấm',
            child: InlinePicker<int>(
              prominent: true,
              placeholder: 'Chọn tổ ấm',
              value: families.selectedFamilyId,
              options: {for (final f in families.families) f.familyId: f.name},
              onChanged: families.selectFamily,
            ),
          ),
          const SizedBox(height: 8),
          if (!family.canRead)
            Text('Bạn chưa có quyền Xem dữ liệu của tổ ấm này.',
                style: AppTypography.bodyMd)
          else ...[
            Tooltip(
              message: 'Đổi kỳ báo cáo',
              child: InlinePicker<OverviewPeriod>(
                prominent: true,
                placeholder: 'Chọn kỳ',
                value: _period,
                options: const {
                  OverviewPeriod.thisMonth: 'Tháng này',
                  OverviewPeriod.lastMonth: 'Tháng trước',
                  OverviewPeriod.thisYear: 'Năm nay',
                  OverviewPeriod.lastYear: 'Năm trước',
                  OverviewPeriod.custom: 'Tùy biến',
                },
                onChanged: (period) {
                  if (period == OverviewPeriod.custom) {
                    _pickDates();
                  } else {
                    setState(() {
                      _period = period;
                      _range = overviewPeriodRange(period, DateTime.now());
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
                key: const ValueKey('overview-date-range'),
                onPressed: _pickDates,
                icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                label: Text(_dateLabel(), style: AppTypography.bodySm)),
            const SizedBox(height: 4),
            OverviewBalanceCard(
                family: family,
                summary: summary,
                reportAvailable:
                    !transactions.loading && transactions.errorMessage == null),
            const SizedBox(height: 20),
            if (transactions.loading)
              const Center(child: CircularProgressIndicator())
            else if (transactions.errorMessage != null)
              TextButton(
                  onPressed: transactions.load,
                  child: const Text('Chưa tải được báo cáo. Thử lại'))
            else ...[
              if (summary.transactions.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child:
                        Text('Chưa có giao dịch đã duyệt trong khoảng này.')),
              _OverviewSection(
                title: 'Biểu đồ thu chi',
                initiallyExpanded: true,
                child: OverviewFlowChart(
                  buckets: overviewBuckets(
                      transactions.transactions, family.familyId, _range),
                  onDetails: () => _showTransactions(summary),
                ),
              ),
              const SizedBox(height: 8),
              _OverviewSection(
                title: 'So sánh với kỳ trước',
                child: _ReportComparisonCard(
                    income: summary.income,
                    expense: summary.expense,
                    net: summary.net,
                    previous: previous,
                    earlier: earlier,
                    onDetails: () => _showTransactions(summary)),
              ),
            ],
            const SizedBox(height: 12),
            _OverviewSection(
              title: 'Phân bổ dòng tiền',
              initiallyExpanded: true,
              child: OverviewJars(categories: family.categories),
            ),
            const SizedBox(height: 12),
            _OverviewSection(
              title: 'Đánh giá & dự đoán tài chính gia đình',
              initiallyExpanded: true,
              child: _ForecastCard(
                  balance: family.totalBudget, expense: month.expense),
            ),
          ],
        ]),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) => ExpansionTile(
        key: PageStorageKey(title),
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(title, style: AppTypography.titleSm),
        children: [child],
      );
}

class _ReportComparisonCard extends StatelessWidget {
  const _ReportComparisonCard(
      {required this.income,
      required this.expense,
      required this.net,
      required this.previous,
      required this.earlier,
      required this.onDetails});

  final double income;
  final double expense;
  final double net;
  final OverviewSummary previous;
  final OverviewSummary earlier;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      income,
      expense,
      previous.income,
      previous.expense,
      earlier.income,
      earlier.expense
    ].reduce((a, b) => a > b ? a : b);
    double ratio(double v) =>
        maxValue == 0 ? 0 : (v / maxValue).clamp(0.0, 1.0);

    Widget bar(
        String label, double incomeVal, double expenseVal, bool highlight) {
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
                      color: AppColors.secondary,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 10,
                    height: 64 * ratio(expenseVal),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
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
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(
                  color: AppColors.secondary,
                  label: 'Thu nhập: ${_shortAmount(income)}'),
              const SizedBox(width: 12),
              _LegendDot(
                  color: AppColors.primary,
                  label: 'Chi tiêu: ${_shortAmount(expense)}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              bar('Kỳ trước nữa', earlier.income, earlier.expense, false),
              bar('Kỳ liền trước', previous.income, previous.expense, false),
              bar('Kỳ hiện tại', income, expense, true),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            children: [
              Text('Chênh lệch thặng dư: ',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Text('${net > 0 ? '+' : ''}${formatCurrency(net)} đ',
                  style: AppTypography.labelMd.copyWith(
                      color:
                          net < 0 ? AppColors.primary : AppColors.secondary)),
            ],
          ),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: onDetails, child: const Text('Xem chi tiết →'))),
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
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: AppTypography.labelSm
                .copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.balance, required this.expense});
  final double balance;
  final double expense;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daily = expense / now.day;
    final forecast =
        balance - daily * (DateTime(now.year, now.month + 1, 0).day - now.day);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Tốc độ chi tiêu tháng này',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.outline)),
                  const SizedBox(height: 4),
                  Text('${formatCurrency(daily)} đ/ngày',
                      style: AppTypography.titleSm),
                ])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Dự đoán số dư cuối tháng',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.outline)),
                  const SizedBox(height: 4),
                  Text('${formatCurrency(forecast)} đ',
                      style: AppTypography.titleSm.copyWith(
                          color: forecast < 0
                              ? AppColors.primary
                              : AppColors.secondary)),
                ])),
          ]),
          const SizedBox(height: 12),
          Text(
              'Ước tính theo mức chi đã duyệt trong tháng, chưa tính thu nhập sắp tới.',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ]));
  }
}

/// Hiển thị khi tài khoản chưa thuộc gia đình nào (hoặc đang tải).
class _EmptyOverview extends StatelessWidget {
  const _EmptyOverview({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.diversity_3, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text('Bạn chưa có tổ ấm nào', style: AppTypography.headlineSm),
              const SizedBox(height: 6),
              Text(
                'Tạo gia đình mới hoặc nhập mã mời từ Chủ hộ để bắt đầu quản lý tài chính chung.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => promptCreateFamily(context),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.add_home_outlined),
                label: const Text('Tạo gia đình mới'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => promptJoinFamily(context),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.vpn_key_outlined),
                label: const Text('Nhập mã mời'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
