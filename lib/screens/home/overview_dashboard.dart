import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/layout/home_tab_header.dart';
import '../../models/family_model.dart';
import '../../utils/format_currency.dart';
import '../../utils/overview_summary.dart';
import '../../utils/category_usage_status.dart';
import '../../widgets/family/category_progress_tile.dart';

final _numbers = AppTypography.titleSm
    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

class OverviewBalanceCard extends StatelessWidget {
  const OverviewBalanceCard(
      {super.key,
      required this.family,
      required this.summary,
      required this.reportAvailable});
  final FamilyDetailModel family;
  final OverviewSummary summary;
  final bool reportAvailable;

  @override
  Widget build(BuildContext context) {
    final members = family.members.take(3).toList();
    const avatarRadius = 13.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: HomeTabColors.border),
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HomeTabColors.peachTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.home_outlined, color: HomeTabColors.coral),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(family.name, style: AppTypography.titleSm)),
          const SizedBox(width: 8),
          Text(family.myRole.label,
              style: AppTypography.labelSm.copyWith(color: HomeTabColors.sage)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (members.isNotEmpty)
              SizedBox(
                width: avatarRadius * (members.length + 1),
                height: avatarRadius * 2,
                child: Stack(
                  children: [
                    for (final (index, member) in members.indexed)
                      PositionedDirectional(
                        start: index * avatarRadius,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: avatarRadius - 1,
                            backgroundColor: const [
                              HomeTabColors.peachTint,
                              HomeTabColors.wheatTint,
                              HomeTabColors.sageTint,
                            ][index],
                            child: Align(
                              alignment: index == members.length - 1
                                  ? AlignmentDirectional.center
                                  : const AlignmentDirectional(-0.75, 0),
                              child: Text(member.initials,
                                  style: AppTypography.labelSm),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (family.members.length > 3)
              Text('+${family.members.length - 3}',
                  style: AppTypography.labelSm),
            Text('${family.members.length} thành viên',
                style: AppTypography.bodySm),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: HomeTabColors.neutral,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  alignment: AlignmentDirectional.centerStart,
                  fit: BoxFit.scaleDown,
                  child: Text('Số dư hiện tại', style: AppTypography.bodySm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  alignment: AlignmentDirectional.centerEnd,
                  fit: BoxFit.scaleDown,
                  child: Text('${formatCurrency(family.totalBudget)} đ',
                      style: AppTypography.amountMd),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _stat('Thu trong kỳ', summary.income, '+')),
          const SizedBox(width: 8),
          Expanded(child: _stat('Chi trong kỳ', summary.expense, '−')),
        ]),
      ]),
    );
  }

  Widget _stat(String label, double value, String sign) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: sign == '+' ? HomeTabColors.sageTint : HomeTabColors.peachTint,
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.bodySm),
        const SizedBox(height: 4),
        Tooltip(
            message: reportAvailable
                ? '$sign${formatCurrency(value)} đ'
                : 'Đang chờ báo cáo',
            child: Text(
                reportAvailable
                    ? '${value == 0 ? '' : sign}${formatCompactCurrency(value)}'
                    : '—',
                style: _numbers.copyWith(
                    color: sign == '+'
                        ? HomeTabColors.sage
                        : HomeTabColors.coral))),
      ]));
}

class OverviewFlowChart extends StatelessWidget {
  const OverviewFlowChart(
      {super.key, required this.buckets, required this.onDetails});
  final List<OverviewBucket> buckets;
  final VoidCallback onDetails;
  static const double _plotHeight = 100;

  @override
  Widget build(BuildContext context) {
    final peak = buckets.fold<double>(
        0,
        (value, b) =>
            math.max(value, math.max(b.summary.income, b.summary.expense)));
    final divisor = peak >= 1000000000
        ? 1000000000.0
        : peak >= 1000000
            ? 1000000.0
            : peak >= 1000
                ? 1000.0
                : 1.0;
    final unit = divisor == 1000000000
        ? 'Tỷ đồng'
        : divisor == 1000000
            ? 'Triệu đồng'
            : divisor == 1000
                ? 'Nghìn đồng'
                : 'Đồng';
    // A round common axis for both series; the zero state keeps a visible axis.
    final scaledPeak = peak / divisor;
    final step = scaledPeak == 0
        ? 1.0
        : math
            .pow(10, (math.log(scaledPeak / 3) / math.ln10).floor())
            .toDouble();
    final tick = scaledPeak == 0 ? 1.0 : (scaledPeak / 3 / step).ceil() * step;
    final ceiling = tick * 3;
    final monthly = buckets.isNotEmpty && buckets.first.label.startsWith('T');
    String number(double value) => value
        .toStringAsFixed(value == value.roundToDouble() ? 0 : 1)
        .replaceAll('.', ',');
    final expenses = buckets.map((b) => b.summary.expense).toList();
    final increasing = expenses.length > 1 &&
        List.generate(expenses.length - 1, (i) => expenses[i + 1] > expenses[i])
            .every((v) => v);
    final decreasing = expenses.length > 1 &&
        List.generate(expenses.length - 1, (i) => expenses[i + 1] < expenses[i])
            .every((v) => v);
    final insight = peak == 0
        ? 'Chưa có thu – chi trong khoảng này.'
        : increasing
            ? 'Chi tăng qua các khoảng đang xem.'
            : decreasing
                ? 'Chi giảm qua các khoảng đang xem.'
                : expenses.length == 1
                    ? 'Thu – chi trong khoảng đang chọn.'
                    : 'So sánh thu – chi theo từng khoảng.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: HomeTabColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(monthly ? 'Thu – chi theo tháng' : 'Thu – chi theo tuần',
            style: AppTypography.titleSm),
        const SizedBox(height: 6),
        Wrap(spacing: 16, runSpacing: 6, children: [
          Text(unit, style: AppTypography.bodySm),
          _legend('Thu', HomeTabColors.sage),
          _legend('Chi', HomeTabColors.coral),
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
          final width = math.max(
              constraints.maxWidth - 40, buckets.length * 70.0 * scale);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 40,
                height: _plotHeight + 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final fraction in [1.0, 2 / 3, 1 / 3, 0.0])
                      Text(number(ceiling * fraction),
                          style: AppTypography.labelSm)
                  ],
                )),
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: width,
                  child: Stack(children: [
                    Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        height: _plotHeight,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                4,
                                (_) => const Divider(
                                    height: 1,
                                    color: AppColors.surfaceContainer)))),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final bucket in buckets)
                            Expanded(
                                child: Column(children: [
                              SizedBox(
                                  height: _plotHeight + 8,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _bar(
                                            bucket,
                                            bucket.summary.income,
                                            HomeTabColors.sage,
                                            'Thu',
                                            divisor,
                                            ceiling),
                                        const SizedBox(width: 4),
                                        _bar(
                                            bucket,
                                            bucket.summary.expense,
                                            HomeTabColors.coral,
                                            'Chi',
                                            divisor,
                                            ceiling),
                                      ])),
                              const SizedBox(height: 8),
                              Text(bucket.label, style: AppTypography.labelSm),
                            ])),
                        ]),
                  ])),
            )),
          ]);
        }),
        const SizedBox(height: 8),
        Text(
            monthly
                ? 'Mỗi cặp cột là một tháng; nhãn là tháng/năm.'
                : 'Mỗi cặp cột tối đa 7 ngày; nhãn là ngày bắt đầu.',
            style: AppTypography.bodySm),
        const Divider(height: 24),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.insights_outlined,
              color: HomeTabColors.coral, size: 22),
          const SizedBox(width: 8),
          Expanded(child: Text(insight, style: AppTypography.bodyMd)),
        ]),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: onDetails, child: const Text('Xem chi tiết →'))),
      ]),
    );
  }

  Widget _bar(OverviewBucket bucket, double amount, Color color, String label,
      double divisor, double ceiling) {
    final start = bucket.range.start;
    final end = bucket.range.end;
    final description = '$label ${start.day}/${start.month}/${start.year} – '
        '${end.day}/${end.month}/${end.year}: ${formatCurrency(amount)} đ';
    return Semantics(
        label: description,
        child: Tooltip(
            message: description,
            child: Container(
                width: 22,
                height: (amount / divisor / ceiling * _plotHeight)
                    .clamp(0.0, _plotHeight),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(5))))));
  }

  Widget _legend(String label, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.bodySm)
      ]);
}

extension on CategoryUsageStatus {
  Color get color => switch (this) {
        CategoryUsageStatus.normal => AppColors.secondary,
        CategoryUsageStatus.warning => const Color(0xFFB45309),
        _ => AppColors.error,
      };

  IconData get icon => switch (this) {
        CategoryUsageStatus.normal => Icons.check_circle_outline,
        CategoryUsageStatus.warning => Icons.warning_amber_rounded,
        CategoryUsageStatus.locked => Icons.lock_outline,
        _ => Icons.error_outline,
      };
}

class OverviewJars extends StatelessWidget {
  const OverviewJars({super.key, required this.categories});
  final List<FinancialCategoryModel> categories;

  void _details(BuildContext context, FinancialCategoryModel category) {
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: AppTypography.headlineSm),
                      const SizedBox(height: 16),
                      Text('Đã chi: ${formatCurrency(category.spent)} đ',
                          style: _numbers),
                      Text('Hạn mức: ${formatCurrency(category.limitAmount)} đ',
                          style: _numbers),
                      const SizedBox(height: 8),
                      Text('Tỷ trọng phân bổ: ${category.allocationPercent}%',
                          style: AppTypography.bodyMd),
                      const SizedBox(height: 8),
                      _statusLabel(categoryUsageStatus(category)),
                      const SizedBox(height: 12),
                      Text(category.amountOfWarning > 0
                          ? 'Ngưỡng cảnh báo: ${formatCurrency(category.amountOfWarning)} đ'
                          : 'Ngưỡng cảnh báo: Đã tắt'),
                      Text(category.amountOfEmergency > 0
                          ? 'Ngưỡng khẩn cấp: ${formatCurrency(category.amountOfEmergency)} đ'
                          : 'Ngưỡng khẩn cấp: Đã tắt'),
                      const SizedBox(height: 12),
                      const Text(
                          'Số liệu danh mục là tổng đã chi do hệ thống ghi nhận, không phụ thuộc bộ lọc ngày báo cáo.'),
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    final statuses = categories.map(categoryUsageStatus).toList();
    final warningCount = statuses.where((s) => s.needsAttention).length;
    final hasRed = statuses
        .any((s) => s.needsAttention && s != CategoryUsageStatus.warning);
    final alertColor =
        hasRed ? AppColors.error : CategoryUsageStatus.warning.color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${categories.length} danh mục chi tiêu · Số tiền rút gọn',
          style: AppTypography.bodySm),
      const SizedBox(height: 6),
      Text('Tổng đã chi của danh mục · Không theo bộ lọc ngày',
          style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
      const SizedBox(height: 12),
      if (categories.isNotEmpty) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, status) in const [
              CategoryUsageStatus.normal,
              CategoryUsageStatus.warning,
              CategoryUsageStatus.depleted,
            ].indexed) ...[
              if (index > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: [
                      HomeTabColors.sageTint,
                      HomeTabColors.wheatTint,
                      HomeTabColors.peachTint,
                    ][index],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.savings_outlined,
                          size: 22, color: status.color),
                      const SizedBox(height: 3),
                      Text(
                        '${status.label}\n${statuses.where((value) => value == status).length} danh mục',
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.labelSm.copyWith(color: status.color),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
      if (warningCount > 0) ...[
        Container(
            key: const ValueKey('overview-jar-alert'),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: alertColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(hasRed ? Icons.error_outline : Icons.warning_amber_rounded,
                  color: alertColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$warningCount danh mục cần chú ý',
                        style:
                            AppTypography.labelMd.copyWith(color: alertColor)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 12, runSpacing: 6, children: [
                      for (final status in CategoryUsageStatus.values)
                        if (status.needsAttention && statuses.contains(status))
                          Text(
                              '${status.label}: ${statuses.where((s) => s == status).length}',
                              style: AppTypography.bodySm
                                  .copyWith(color: status.color)),
                    ]),
                  ])),
            ])),
        const SizedBox(height: 12),
      ],
      Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Đã chi / Hạn mức',
                style:
                    AppTypography.labelMd.copyWith(color: AppColors.outline)),
            if (categories.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Tổ ấm chưa có danh mục chi tiêu.')),
            for (var i = 0; i < categories.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: AppColors.surfaceContainer),
              _jar(context, categories[i]),
            ],
            if (categories.isNotEmpty)
              Text('Chạm vào danh mục để xem số tiền đầy đủ →',
                  style:
                      AppTypography.bodySm.copyWith(color: AppColors.outline)),
          ])),
    ]);
  }

  Widget _jar(BuildContext context, FinancialCategoryModel category) {
    final ratio =
        category.limitAmount > 0 ? category.spent / category.limitAmount : null;
    final status = categoryUsageStatus(category);
    final color = status.color;
    return InkWell(
        key: ValueKey('overview-jar-${category.financialCategoryId}'),
        onTap: () => _details(context, category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(categoryIcon(category.name),
                      size: 22, color: AppColors.primary)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Text(category.name,
                                  style: AppTypography.labelMd)),
                          const SizedBox(width: 8),
                          Text(
                              ratio == null ? '—' : '${(ratio * 100).round()}%',
                              style: AppTypography.labelMd.copyWith(
                                color: color,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              )),
                        ]),
                    const SizedBox(height: 4),
                    Text(
                        '${formatCompactCurrency(category.spent)} / ${formatCompactCurrency(category.limitAmount)}',
                        style: AppTypography.bodySm.copyWith(
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ])),
                    const SizedBox(height: 6),
                    _statusLabel(status),
                    if (ratio == null)
                      Text('Chưa có hạn mức', style: AppTypography.bodySm),
                    const SizedBox(height: 8),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                            value: (ratio ?? 0).clamp(0.0, 1.0),
                            minHeight: 5,
                            color: color,
                            backgroundColor: AppColors.surfaceContainer)),
                  ])),
            ])));
  }

  Widget _statusLabel(CategoryUsageStatus status) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 5),
          Flexible(
              child: Text(status.label,
                  style: AppTypography.labelSm.copyWith(color: status.color))),
        ],
      );
}
