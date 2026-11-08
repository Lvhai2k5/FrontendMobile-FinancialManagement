import 'package:dio/dio.dart';
import 'package:finance_management/api/transaction_api.dart';
import 'package:finance_management/models/transaction_model.dart';
import 'package:finance_management/providers/transaction_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _OfflineApi extends TransactionApi {
  final sent = <Map<String, dynamic>>[];
  bool offline = true;
  int? status;

  @override
  Future<TransactionModel> submitQueued(Map<String, dynamic> payload) async {
    sent.add(Map.of(payload));
    final request = RequestOptions(path: '/transactions');
    if (offline) {
      throw DioException(
          requestOptions: request, type: DioExceptionType.connectionError);
    }
    if (status case final code?) {
      throw DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: request, statusCode: code),
      );
    }
    return TransactionModel.fromJson({
      'transactionId': 1,
      'content': payload['content'],
      'amount': payload['amount'],
      'status': 'PENDING',
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
      'Bản ghi vẫn còn khi mở lại, tách theo tài khoản và dùng lại mã chống trùng',
      () async {
    final api = _OfflineApi();
    final provider = TransactionProvider(api: api);
    await provider.setSession(1);
    final result = await provider.addManualTransaction(
      financialCategoryId: 3,
      content: 'Ăn sáng',
      amount: 42000,
      type: TransactionType.expense,
    );
    expect(result.queued, isTrue);
    expect(provider.pending.single.content, 'Ăn sáng');

    final reopened = TransactionProvider(api: api);
    await reopened.setSession(2);
    expect(reopened.pending, isEmpty);
    await reopened.setSession(1);
    expect(reopened.pending, hasLength(1));
    api.offline = false;
    expect(await reopened.syncPending(), 1);
    expect(api.sent.last, api.sent.first);
    expect(reopened.pending, isEmpty);
    expect(reopened.transactions.single.status, TransactionStatus.pend);
    await reopened.setSession(2);
    await reopened.setSession(1);
    expect(reopened.pending, isEmpty);
  });

  test('Giao dịch bị thu hồi quyền Ghi vẫn hiển thị lỗi và không tự gửi lặp',
      () async {
    final api = _OfflineApi();
    final provider = TransactionProvider(api: api);
    await provider.setSession(1);
    await provider.addManualTransaction(
      financialCategoryId: 3,
      content: 'Ăn sáng',
      amount: 42000,
      type: TransactionType.expense,
    );
    api.offline = false;
    api.status = 403;
    expect(await provider.syncPending(), 0);
    expect(provider.pending.single.error, isNotNull);
    expect(provider.hasPendingRetry, isFalse);
    expect(await provider.syncPending(), 0);
    expect(api.sent, hasLength(2));
    await provider.discardPending(provider.pending.single.id);
    expect(provider.pending, isEmpty);
  });
}
