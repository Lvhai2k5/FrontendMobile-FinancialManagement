import 'dart:math';

import 'transaction_model.dart';

class PendingTransaction {
  PendingTransaction(this.payload, {this.error});

  factory PendingTransaction.create({
    required int personId,
    required int categoryId,
    required String content,
    required double amount,
    required TransactionType type,
  }) {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    final id = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    return PendingTransaction({
      'clientRequestId': id,
      'expectedPersonId': personId,
      'financialCategoryId': categoryId,
      'content': content,
      'amount': amount,
      'transactionType': type == TransactionType.income ? 'INCOME' : 'EXPENSE',
      'occurredAt': DateTime.now().toIso8601String(),
    });
  }

  final Map<String, dynamic> payload;
  final String? error;

  String get id => payload['clientRequestId'] as String;
  String get content => payload['content'] as String;
  double get amount => (payload['amount'] as num).toDouble();

  factory PendingTransaction.fromJson(Map<String, dynamic> json) =>
      PendingTransaction(json['payload'] as Map<String, dynamic>,
          error: json['error'] as String?);

  Map<String, dynamic> toJson() => {'payload': payload, 'error': error};
}
