import '../utils/api_error.dart';

/// Loại giao dịch — khớp `TransactionType`, xem `BUSINESS-REQUIREMENTS.md`
/// mục 5.
enum TransactionType { income, expense }

/// Trạng thái giao dịch — khớp `TransactionStatus` mục 5. App mock chỉ dùng
/// `approve`/`pend`/`reject` (đủ cho luồng duyệt hiển thị trên UI).
enum TransactionStatus { approve, pend, reject }

extension TransactionStatusLabel on TransactionStatus {
  String get label => switch (this) {
        TransactionStatus.approve => 'Đã duyệt',
        TransactionStatus.pend => 'Chờ duyệt',
        TransactionStatus.reject => 'Từ chối',
      };
}

/// 1 giao dịch — khớp entity `Transaction` mục 4.7 (rút gọn cho hiển thị
/// danh sách, Backend chưa có endpoint `/transactions`).
class TransactionModel {
  const TransactionModel({
    required this.transactionId,
    required this.content,
    required this.amount,
    required this.type,
    required this.status,
    required this.categoryName,
    required this.createdAt,
    this.familyId,
    this.financialCategoryId,
  });

  final int transactionId;
  final String content;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String categoryName;
  final DateTime createdAt;
  final int? familyId;
  final int? financialCategoryId;

  /// Backend trả 	ype = INCOME/EXPENSE, status = DRAFT/PENDING/REVIEW/
  /// APPROVED/REJECTED/OFFLINE; Mobile gộp mọi trạng thái chưa quyết định
  /// thành pend.
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        transactionId: asInt(json['transactionId']),
        content: json['content'] as String? ?? '',
        amount: asDouble(json['amount']),
        type: json['type'] == 'INCOME'
            ? TransactionType.income
            : TransactionType.expense,
        status: switch (json['status']) {
          'APPROVED' => TransactionStatus.approve,
          'REJECTED' => TransactionStatus.reject,
          _ => TransactionStatus.pend,
        },
        categoryName: json['categoryName'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        familyId: (json['familyId'] as num?)?.toInt(),
        financialCategoryId: (json['financialCategoryId'] as num?)?.toInt(),
      );
}
