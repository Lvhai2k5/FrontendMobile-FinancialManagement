import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_management/api/transaction_api.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:finance_management/utils/format_currency.dart';
import 'package:finance_management/utils/overview_summary.dart';

TransactionModel entry(int id, DateTime date, double amount,
        {int familyId = 1,
        TransactionStatus status = TransactionStatus.approve,
        TransactionType type = TransactionType.income}) =>
    TransactionModel(
      transactionId: id,
      content: 'Giao dịch thử',
      amount: amount,
      type: type,
      status: status,
      categoryName: 'Hũ thử',
      createdAt: date,
      familyId: familyId,
    );

class _PagedApi extends TransactionApi {
  final pages = <int>[];
  @override
  Future<List<TransactionModel>> list({int page = 0, int size = 100}) async {
    pages.add(page);
    return List.generate(page == 0 ? 100 : 1,
        (index) => entry(page * 100 + index, DateTime(2026, 11, 1), 1));
  }
}

void main() {
  test('Biểu đồ chia tuần không mất/trùng giao dịch tại biên', () {
    final range = DateTimeRange(
        start: DateTime(2026, 10, 29), end: DateTime(2026, 11, 10));
    final source = [
      entry(1, DateTime(2026, 10, 29), 10),
      entry(2, DateTime(2026, 11, 4, 23, 59), 20),
      entry(3, DateTime(2026, 11, 5), 30, type: TransactionType.expense),
      entry(4, DateTime(2026, 11, 10, 23, 59), 40),
      entry(5, DateTime(2026, 11, 11), 999),
      entry(6, DateTime(2026, 11, 1), 999, familyId: 2),
      entry(7, DateTime(2026, 11, 1), 999, status: TransactionStatus.pend),
    ];
    final buckets = overviewBuckets(source, 1, range);
    expect(buckets.length, 2);
    expect(buckets[0].summary.income, 30);
    expect(buckets[1].summary.income, 40);
    expect(buckets[1].summary.expense, 30);
    expect(buckets.last.range.end, range.end);
    expect(buckets.expand((b) => b.summary.transactions).length, 4);
  });

  test('Khoảng dài chia tháng, giữ ngày đầu/cuối và tháng rỗng', () {
    final range =
        DateTimeRange(start: DateTime(2024, 1, 31), end: DateTime(2024, 3, 10));
    final buckets = overviewBuckets([
      entry(1, DateTime(2024, 2, 29, 23, 59), 20),
      entry(2, DateTime(2024, 3, 10, 23, 59), 30),
      entry(3, DateTime(2024, 3, 11), 999),
    ], 1, range);
    expect(buckets.length, 3);
    expect(buckets.first.summary.income, 0);
    expect(buckets[1].summary.income, 20);
    expect(buckets.last.summary.income, 30);
    expect(buckets[1].range.end, DateTime(2024, 2, 29));
  });

  test('Kỳ tháng/năm xử lý đầu năm và năm nhuận', () {
    final january =
        overviewPeriodRange(OverviewPeriod.lastMonth, DateTime(2026, 1, 2));
    expect(january.start, DateTime(2025, 12, 1));
    expect(january.end, DateTime(2025, 12, 31));
    expect(
        overviewPeriodRange(OverviewPeriod.lastMonth, DateTime(2024, 3, 5)).end,
        DateTime(2024, 2, 29));
    final year =
        overviewPeriodRange(OverviewPeriod.lastYear, DateTime(2026, 11, 2));
    expect(year.start, DateTime(2025, 1, 1));
    expect(year.end, DateTime(2025, 12, 31));
  });

  test('Tính đúng gia đình, trạng thái và cả ngày cuối; không lấy ngày kế tiếp',
      () {
    final summary = OverviewSummary(
        [
          entry(1, DateTime(2026, 11, 1), 200),
          entry(2, DateTime(2026, 11, 2, 23, 59, 59), 80,
              type: TransactionType.expense),
          entry(3, DateTime(2026, 11, 3), 999),
          entry(4, DateTime(2026, 11, 1), 999, familyId: 2),
          entry(5, DateTime(2026, 11, 1), 999, status: TransactionStatus.pend),
          entry(6, DateTime(2026, 11, 1), 999,
              status: TransactionStatus.reject),
          entry(7, DateTime(2026, 10, 31, 23, 59), 999),
        ],
        1,
        DateTimeRange(
            start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 2)));
    expect(summary.income, 200);
    expect(summary.expense, 80);
    expect(summary.net, 120);
    expect(summary.transactions.map((e) => e.transactionId), [2, 1]);
  });

  test('Tiền rút gọn dùng dấu phẩy, đơn vị rõ ràng và đúng dấu âm', () {
    expect(formatCompactCurrency(61830000), '61,83 triệu đ');
    expect(formatCompactCurrency(48500000), '48,5 triệu đ');
    expect(formatCompactCurrency(-29170000), '-29,17 triệu đ');
    expect(formatCompactCurrency(1000), '1 nghìn đ');
    expect(formatCompactCurrency(2000000000), '2 tỷ đ');
    expect(formatCompactCurrency(0), '0 đ');
  });

  test('Tải thêm trang giao dịch để báo cáo không thiếu lịch sử', () async {
    final api = _PagedApi();
    final provider = TransactionProvider(api: api);
    await provider.load();
    expect(api.pages, [0, 1]);
    expect(provider.transactions.length, 101);
    expect(provider.errorMessage, isNull);
    provider.dispose();
  });
}
