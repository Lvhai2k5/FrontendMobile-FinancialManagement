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
  });

  final int transactionId;
  final String content;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String categoryName;
  final DateTime createdAt;
}
