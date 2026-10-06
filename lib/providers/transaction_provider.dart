import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';

/// Logic + state cho nghiệp vụ Giao dịch (`Transaction`). Backend chưa có
/// endpoint `/transactions` nên seed dữ liệu mock tại đây — xem ghi chú ở
/// đầu `family_provider.dart` về quy ước tạm thời này.
class TransactionProvider with ChangeNotifier {
  TransactionProvider() {
    _seed();
  }

  final List<TransactionModel> _transactions = [];
  int _nextId = 1000;

  List<TransactionModel> get transactions {
    final sorted = List<TransactionModel>.of(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  void addManualTransaction({
    required String content,
    required double amount,
    required TransactionType type,
    required String categoryName,
  }) {
    _transactions.insert(
      0,
      TransactionModel(
        transactionId: _nextId++,
        content: content,
        amount: amount,
        type: type,
        status: TransactionStatus.pend,
        categoryName: categoryName,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void _seed() {
    final now = DateTime.now();
    DateTime at(int daysAgo, int hour, int minute) => DateTime(
        now.year, now.month, now.day, hour, minute).subtract(Duration(days: daysAgo));

    _transactions.addAll([
      TransactionModel(
        transactionId: _nextId++,
        content: 'Siêu thị WinMart',
        amount: 620000,
        type: TransactionType.expense,
        status: TransactionStatus.approve,
        categoryName: 'Hũ thiết yếu',
        createdAt: at(0, 10, 15),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Tiền điện & Nước sinh hoạt',
        amount: 1850000,
        type: TransactionType.expense,
        status: TransactionStatus.approve,
        categoryName: 'Quỹ chung',
        createdAt: at(0, 8, 30),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Học thêm tiếng Anh Bé Bơ',
        amount: 1200000,
        type: TransactionType.expense,
        status: TransactionStatus.pend,
        categoryName: 'Hũ giáo dục',
        createdAt: at(0, 7, 0),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Nạp lương công ty',
        amount: 25000000,
        type: TransactionType.income,
        status: TransactionStatus.approve,
        categoryName: 'Thu nhập chính',
        createdAt: at(1, 17, 45),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Cafe gia đình & bạn bè',
        amount: 145000,
        type: TransactionType.expense,
        status: TransactionStatus.approve,
        categoryName: 'Hũ hưởng thụ',
        createdAt: at(1, 14, 20),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Đóng góp quỹ khuyến học',
        amount: 500000,
        type: TransactionType.expense,
        status: TransactionStatus.approve,
        categoryName: 'Hũ cho đi',
        createdAt: at(1, 9, 10),
      ),
      TransactionModel(
        transactionId: _nextId++,
        content: 'Mua sắm sách giáo khoa',
        amount: 340000,
        type: TransactionType.expense,
        status: TransactionStatus.approve,
        categoryName: 'Hũ giáo dục',
        createdAt: at(4, 16, 30),
      ),
    ]);
  }
}
