import 'package:flutter/foundation.dart';

import '../api/transaction_api.dart';
import '../models/transaction_model.dart';
import '../utils/api_error.dart';

/// State giao dịch của mọi gia đình người dùng tham gia — lấy từ Backend.
class TransactionProvider with ChangeNotifier {
  TransactionProvider({TransactionApi? api}) : _api = api ?? TransactionApi();

  final TransactionApi _api;
  final List<TransactionModel> _transactions = [];

  bool loading = false;
  String? errorMessage;

  /// Mới nhất trước.
  List<TransactionModel> get transactions {
    final sorted = List<TransactionModel>.of(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  List<TransactionModel> forFamily(int? familyId) =>
      transactions.where((t) => t.familyId == familyId).toList();

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final items = await _api.list();
      _transactions
        ..clear()
        ..addAll(items);
    } catch (e) {
      errorMessage = apiErrorMessage(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Trả giao dịch vừa tạo, hoặc ném lỗi message để screen hiển thị.
  Future<({TransactionModel? created, String? error})> addManualTransaction({
    required int financialCategoryId,
    required String content,
    required double amount,
    required TransactionType type,
  }) async {
    try {
      final created = await _api.create(
          financialCategoryId: financialCategoryId,
          content: content,
          amount: amount,
          type: type);
      _transactions.insert(0, created);
      notifyListeners();
      return (created: created, error: null);
    } catch (e) {
      return (created: null, error: apiErrorMessage(e));
    }
  }

  void clear() {
    _transactions.clear();
    errorMessage = null;
    notifyListeners();
  }
}
