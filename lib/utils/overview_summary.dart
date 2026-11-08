import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

enum OverviewPeriod { thisMonth, lastMonth, thisYear, lastYear, custom }

DateTimeRange overviewPeriodRange(OverviewPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return switch (period) {
    OverviewPeriod.lastMonth => DateTimeRange(
        start: DateTime(now.year, now.month - 1),
        end: DateTime(now.year, now.month, 0)),
    OverviewPeriod.thisYear =>
      DateTimeRange(start: DateTime(now.year), end: today),
    OverviewPeriod.lastYear => DateTimeRange(
        start: DateTime(now.year - 1), end: DateTime(now.year, 1, 0)),
    _ => DateTimeRange(start: DateTime(now.year, now.month), end: today),
  };
}

/// Báo cáo chỉ tính giao dịch đã duyệt, gồm cả ngày đầu và ngày cuối.
class OverviewSummary {
  OverviewSummary(
      Iterable<TransactionModel> source, int familyId, DateTimeRange range) {
    final start = DateUtils.dateOnly(range.start);
    final end = DateTime(range.end.year, range.end.month, range.end.day + 1);
    transactions = source.where((transaction) {
      final date = transaction.createdAt.toLocal();
      return transaction.familyId == familyId &&
          transaction.status == TransactionStatus.approve &&
          !date.isBefore(start) &&
          date.isBefore(end);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
  }

  late final List<TransactionModel> transactions;
  double income = 0;
  double expense = 0;
  double get net => income - expense;
}

/// Seven-day buckets for short ranges, months for year/long-range reports.
/// Calendar constructors avoid dropping a day at daylight-saving boundaries.
class OverviewBucket {
  const OverviewBucket(this.range, this.summary, this.label);
  final DateTimeRange range;
  final OverviewSummary summary;
  final String label;
}

List<OverviewBucket> overviewBuckets(
    Iterable<TransactionModel> source, int familyId, DateTimeRange range) {
  final start = DateUtils.dateOnly(range.start);
  final end = DateUtils.dateOnly(range.end);
  final monthly = end.difference(start).inDays > 35;
  final result = <OverviewBucket>[];
  var cursor = start;
  while (!cursor.isAfter(end)) {
    final next = monthly
        ? DateTime(cursor.year, cursor.month + 1)
        : DateTime(cursor.year, cursor.month, cursor.day + 7);
    final last = DateTime(next.year, next.month, next.day - 1);
    final bucket =
        DateTimeRange(start: cursor, end: last.isAfter(end) ? end : last);
    result.add(OverviewBucket(
        bucket,
        OverviewSummary(source, familyId, bucket),
        monthly
            ? 'T${cursor.month}/${cursor.year.toString().substring(2)}'
            : '${cursor.day}/${cursor.month}'));
    cursor = next;
  }
  return result;
}
