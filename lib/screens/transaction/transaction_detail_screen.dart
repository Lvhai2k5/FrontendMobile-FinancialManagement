import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/transaction_api.dart';
import '../../config/theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/api_error.dart';
import '../../utils/format_currency.dart';
import '../../widgets/layout/home_tab_header.dart';

/// Chi tiết 1 giao dịch. Mọi thành viên gia đình đều xem được; nút Duyệt/Từ
/// chối chỉ hiện khi giao dịch đang chờ và người dùng có quyền APPROVAL.
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionModel? _transaction;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = context
        .read<TransactionProvider>()
        .transactions
        .where((t) => t.transactionId == widget.transactionId)
        .firstOrNull;
    if (cached != null) _transaction = cached;
    try {
      final fresh = await TransactionApi().get(widget.transactionId);
      if (!mounted) return;
      setState(() {
        _transaction = fresh;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_transaction == null) setState(() => _error = apiErrorMessage(e));
    }
  }

  Future<void> _decide(bool approved) async {
    setState(() => _busy = true);
    final error = await context
        .read<TransactionProvider>()
        .decide(widget.transactionId, approved: approved);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(approved ? 'Đã duyệt giao dịch.' : 'Đã từ chối giao dịch.')));
    await _load();
  }

  String _dateText(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final l = d.toLocal();
    return '${two(l.day)}/${two(l.month)}/${l.year} ${two(l.hour)}:${two(l.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaction;
    final family = t?.familyId == null
        ? null
        : context.watch<FamilyProvider>().detail(t!.familyId);
    final canDecide = t != null &&
        t.status == TransactionStatus.pend &&
        family?.canApprove == true;
    return Scaffold(
      backgroundColor: HomeTabColors.canvas,
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        backgroundColor: HomeTabColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: t == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroCard(transaction: t),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HomeTabColors.border),
                  ),
                  child: Column(children: [
                    _InfoRow(Icons.notes_outlined, 'Nội dung', t.content),
                    _InfoRow(
                        Icons.category_outlined, 'Danh mục', t.categoryName),
                    if (family != null)
                      _InfoRow(Icons.home_outlined, 'Gia đình', family.name),
                    _InfoRow(Icons.person_outline, 'Người tạo',
                        t.createdPersonName ?? '—'),
                    _InfoRow(
                        Icons.schedule, 'Thời gian', _dateText(t.createdAt),
                        last: true),
                  ]),
                ),
              ],
            ),
      bottomNavigationBar: canDecide
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border(top: BorderSide(color: HomeTabColors.border)),
                ),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _decide(false),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Từ chối'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TransactionStatus.reject.foreground,
                        side: BorderSide(
                            color: TransactionStatus.reject.foreground),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : () => _decide(true),
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Duyệt'),
                      style: FilledButton.styleFrom(
                        backgroundColor: TransactionStatus.approve.foreground,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          : null,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isExpense = t.type == TransactionType.expense;
    final statusBg = t.status.background;
    final statusFg = t.status.foreground;
    final statusIcon = switch (t.status) {
      TransactionStatus.approve => Icons.check_circle_outline,
      TransactionStatus.pend => Icons.hourglass_top,
      TransactionStatus.reject => Icons.cancel_outlined,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isExpense ? HomeTabColors.peachTint : HomeTabColors.sageTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: isExpense ? HomeTabColors.coral : HomeTabColors.sage),
        ),
        const SizedBox(height: 10),
        Text(isExpense ? 'Chi tiêu' : 'Thu nhập',
            style: AppTypography.labelMd
                .copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          '${isExpense ? '-' : '+'}${formatCurrency(t.amount)} đ',
          style: AppTypography.headlineSm.copyWith(
              fontSize: 30,
              color: isExpense ? HomeTabColors.coral : HomeTabColors.sage),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: statusBg, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(statusIcon, size: 14, color: statusFg),
            const SizedBox(width: 5),
            Text(t.status.label,
                style: AppTypography.labelMd.copyWith(color: statusFg)),
          ]),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value, {this.last = false});

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.surfaceContainer)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.outline),
            const SizedBox(width: 10),
            SizedBox(
                width: 84,
                child: Text(label,
                    style: AppTypography.labelMd
                        .copyWith(color: AppColors.outline))),
            Expanded(
                child: Text(value,
                    textAlign: TextAlign.right, style: AppTypography.bodyMd)),
          ],
        ),
      );
}
