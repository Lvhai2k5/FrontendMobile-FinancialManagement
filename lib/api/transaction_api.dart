import 'api_client.dart';
import '../models/transaction_model.dart';

/// Gọi endpoint giao dịch (`/api/v1/transactions`). Danh sách trả về dạng
/// `Page<T>` (`content`, `totalElements`...) theo `TECH-API.md` mục 4.
class TransactionApi {
  Future<List<TransactionModel>> list({int page = 0, int size = 100}) async {
    final res = await apiClient.get('/transactions', queryParameters: {
      'page': page,
      'size': size,
      'sort': 'createdAt,desc'
    });
    final content = (res.data as Map<String, dynamic>)['content'] as List;
    return content
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> create({
    required int financialCategoryId,
    required String content,
    required double amount,
    required TransactionType type,
  }) async {
    final res = await apiClient.post('/transactions', data: {
      'financialCategoryId': financialCategoryId,
      'content': content,
      'amount': amount,
      'transactionType': type == TransactionType.income ? 'INCOME' : 'EXPENSE',
    });
    return TransactionModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> approve(int transactionId) async {
    await apiClient.post('/transactions/$transactionId/approve');
  }

  Future<void> reject(int transactionId) async {
    await apiClient.post('/transactions/$transactionId/reject');
  }
}
