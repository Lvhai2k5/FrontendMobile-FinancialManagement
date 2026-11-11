import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../widgets/common/compact_date_range_dialog.dart';
import '../../widgets/layout/home_tab_header.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/format_currency.dart';
import 'offline_queue_panel.dart';

typedef _SearchOptions = ({DateTimeRange? range, TransactionType? type});

String _rangeLabel(BuildContext context, DateTimeRange range) {
  final date = MaterialLocalizations.of(context).formatCompactDate;
  return '${date(range.start)} – ${date(range.end)}';
}

/// Tab "Giao dịch" — 4 cách tạo giao dịch (chỉ "Nhập thủ công" hoạt động
/// thật, 3 kênh còn lại chưa có trong phạm vi Backend hiện tại, xem
/// `BUSINESS-REQUIREMENTS.md` mục 3.4.1) + danh sách giao dịch gộp theo
/// ngày. Thiết kế theo `finnest_tab_giao_d_ch`.
class TransactionListTab extends StatefulWidget {
  const TransactionListTab({super.key, this.familyId});

  final int? familyId;

  @override
  State<TransactionListTab> createState() => _TransactionListTabState();
}

class _TransactionListTabState extends State<TransactionListTab> {
  final _searchController = TextEditingController();
  late int _filterIndex = widget.familyId == null ? 0 : 3;
  _SearchOptions _options = (range: null, type: null);

  static const _filters = ['Tất cả', 'Hôm nay', 'Tuần này', 'Tháng này'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sẽ có ở bản cập nhật tiếp theo.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
      ),
    );
  }

  Future<void> _openSearchOptions() async {
    FocusScope.of(context).unfocus();
    final options = await showDialog<_SearchOptions>(
      context: context,
      builder: (_) => _TransactionSearchDialog(initial: _options),
    );
    if (mounted && options != null) setState(() => _options = options);
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> items) {
    if (_options.range case final range?) {
      return items.where((t) {
        final day = DateUtils.dateOnly(t.createdAt.toLocal());
        return !day.isBefore(range.start) && !day.isAfter(range.end);
      }).toList();
    }
    final now = DateTime.now();
    bool sameDay(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;
    switch (_filterIndex) {
      case 1:
        return items.where((t) => sameDay(t.createdAt)).toList();
      case 2:
        return items
            .where((t) => now.difference(t.createdAt).inDays <= 7)
            .toList();
      case 3:
        return items
            .where((t) =>
                t.createdAt.year == now.year && t.createdAt.month == now.month)
            .toList();
      default:
        return items;
    }
  }

  String _groupLabel(DateTime date, DateTime now) {
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (diff == 0) return 'Hôm nay, ${date.day} Tháng ${date.month}';
    if (diff == 1) return 'Hôm qua, ${date.day} Tháng ${date.month}';
    return '${date.day} Tháng ${date.month}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<FamilyProvider>();
    final all = context
        .watch<TransactionProvider>()
        .transactions
        .where((transaction) =>
            (widget.familyId == null ||
                widget.familyId == transaction.familyId) &&
            (transaction.familyId == null ||
                families.detail(transaction.familyId)?.canRead == true))
        .toList();
    final now = DateTime.now();
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _applyFilter(all).where((transaction) =>
        (_options.type == null || transaction.type == _options.type) &&
        (query.isEmpty ||
            transaction.content.toLowerCase().contains(query) ||
            transaction.categoryName.toLowerCase().contains(query)));

    final groups = <String, List<TransactionModel>>{};
    for (final t in filtered) {
      final label = _groupLabel(t.createdAt, now);
      groups.putIfAbsent(label, () => []).add(t);
    }

    return RefreshIndicator(
        onRefresh: () async {
          final transactions = context.read<TransactionProvider>();
          await Future.wait([families.load(), transactions.load()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.familyId == null) ...[
                const HomeTabHeader(
                    title: 'Giao dịch',
                    artwork: HomeTabArtwork.transactions,
                    icon: Icons.receipt_long_outlined),
                Text('Phương thức tạo giao dịch',
                    style: AppTypography.headlineSm),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent:
                      54 + MediaQuery.textScalerOf(context).scale(48),
                  children: [
                    _MethodCard(
                      icon: Icons.edit_note,
                      fill: HomeTabColors.sageTint,
                      ink: HomeTabColors.sage,
                      title: 'Nhập thủ công',
                      subtitle: 'Điền biểu mẫu',
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.transactionForm,
                        arguments:
                            context.read<FamilyProvider>().selectedFamilyId,
                      ),
                    ),
                    _MethodCard(
                      icon: Icons.document_scanner_outlined,
                      fill: HomeTabColors.wheatTint,
                      ink: HomeTabColors.amber,
                      title: 'Quét hoá đơn',
                      onTap: () => _showComingSoon('Quét hoá đơn AI'),
                    ),
                    _MethodCard(
                      icon: Icons.mic_none,
                      fill: HomeTabColors.peachTint,
                      ink: HomeTabColors.coral,
                      title: 'Ghi âm giọng nói',
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.transactionVoice,
                        arguments:
                            context.read<FamilyProvider>().selectedFamilyId,
                      ),
                    ),
                    _MethodCard(
                      icon: Icons.center_focus_weak,
                      fill: AppColors.pastelLavender,
                      ink: const Color(0xFF604675),
                      title: 'Quét đồ vật',
                      onTap: () => _showComingSoon('Quét đồ vật'),
                    ),
                  ],
                ),
                const OfflineQueuePanel(),
              ],
              const SizedBox(height: 20),
              Text('Lịch sử giao dịch', style: AppTypography.headlineSm),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: AppColors.outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTypography.bodyMd,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm giao dịch...',
                          hintStyle: AppTypography.bodyMd
                              .copyWith(color: AppColors.outline),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tùy biến tìm kiếm giao dịch',
                      onPressed: _openSearchOptions,
                      icon: Badge(
                        isLabelVisible:
                            _options.range != null || _options.type != null,
                        child: const Icon(Icons.tune, size: 18),
                      ),
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < _filters.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filters[i]),
                        selected: _options.range == null && _filterIndex == i,
                        onSelected: (_) => setState(() {
                          _filterIndex = i;
                          _options = (range: null, type: _options.type);
                        }),
                        selectedColor: HomeTabColors.sageTint,
                        backgroundColor: AppColors.surfaceContainerLowest,
                        labelStyle: AppTypography.labelSm.copyWith(
                            color: _options.range == null && _filterIndex == i
                                ? HomeTabColors.sage
                                : AppColors.onSurfaceVariant),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        side: BorderSide.none,
                      ),
                    ),
                  if (_options.range case final range?)
                    InputChip(
                      label: Text(_rangeLabel(context, range)),
                      onDeleted: () => setState(() {
                        _options = (range: null, type: _options.type);
                      }),
                    ),
                  if (_options.type case final type?)
                    InputChip(
                      label: Text(type == TransactionType.income
                          ? 'Thu nhập'
                          : 'Chi tiêu'),
                      onDeleted: () => setState(() {
                        _options = (range: _options.range, type: null);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('Không có giao dịch nào trong khoảng này.',
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.outline)),
                  ),
                )
              else
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(entry.key, style: AppTypography.labelMd),
                          ],
                        ),
                        Text('${entry.value.length} giao dịch',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.outline)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        for (var i = 0; i < entry.value.length; i++) ...[
                          _TransactionTile(transaction: entry.value[i]),
                          if (i != entry.value.length - 1)
                            Divider(
                                height: 1, color: AppColors.surfaceContainer),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ));
  }
}

class _TransactionSearchDialog extends StatefulWidget {
  const _TransactionSearchDialog({required this.initial});

  final _SearchOptions initial;

  @override
  State<_TransactionSearchDialog> createState() =>
      _TransactionSearchDialogState();
}

class _TransactionSearchDialogState extends State<_TransactionSearchDialog> {
  late DateTimeRange? _range = widget.initial.range;
  late TransactionType? _type = widget.initial.type;

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(1900),
      lastDate: DateUtils.dateOnly(DateTime.now()),
      helpText: 'Chọn khoảng ngày',
      cancelText: 'Hủy',
      saveText: 'Chọn khoảng này',
      confirmText: 'Chọn khoảng này',
      switchToInputEntryModeIcon: const Icon(Icons.edit_calendar_outlined),
      builder: compactDateRangeDialog,
    );
    if (mounted && range != null) setState(() => _range = range);
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tùy biến tìm kiếm', style: AppTypography.headlineSm),
              const SizedBox(height: 16),
              Text('Khoảng thời gian', style: AppTypography.titleSm),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(_range == null
                    ? 'Chọn khoảng ngày'
                    : _rangeLabel(context, _range!)),
              ),
              const SizedBox(height: 16),
              Text('Loại giao dịch', style: AppTypography.titleSm),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final (type, label)
                      in const <(TransactionType?, String)>[
                    (null, 'Tất cả loại'),
                    (TransactionType.income, 'Thu nhập'),
                    (TransactionType.expense, 'Chi tiêu'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pop<_SearchOptions>((range: _range, type: _type)),
                child: const Text('Áp dụng bộ lọc'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _range = null;
                  _type = null;
                }),
                child: const Text('Đặt lại'),
              ),
            ],
          ),
        ),
      );
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.fill,
    required this.ink,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color fill;
  final Color ink;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: HomeTabColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 23, color: ink),
              const SizedBox(height: 5),
              Text(title,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd
                      .copyWith(fontWeight: FontWeight.w600)),
              if (subtitle case final text?)
                Text(text,
                    textAlign: TextAlign.center, style: AppTypography.bodySm),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    String two(int n) => n.toString().padLeft(2, '0');

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.transactionDetail,
          arguments: transaction.transactionId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isExpense
                    ? HomeTabColors.peachTint
                    : HomeTabColors.sageTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color:
                    isExpense ? AppColors.onSurfaceVariant : HomeTabColors.sage,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.content,
                      style: AppTypography.bodyMd,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    '${two(transaction.createdAt.hour)}:${two(transaction.createdAt.minute)} · ${transaction.categoryName}',
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${formatCurrency(transaction.amount)} đ',
                  style: AppTypography.titleSm.copyWith(
                      color:
                          isExpense ? HomeTabColors.coral : HomeTabColors.sage),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction.status.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(transaction.status.label,
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
