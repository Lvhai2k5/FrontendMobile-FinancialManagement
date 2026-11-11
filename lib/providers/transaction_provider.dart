import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/pending_transaction.dart';

import '../api/transaction_api.dart';
import '../config/env.dart';
import '../models/transaction_model.dart';
import '../utils/api_error.dart';

/// State giao dịch của mọi gia đình người dùng tham gia — lấy từ Backend.
class TransactionProvider with ChangeNotifier {
  TransactionProvider({TransactionApi? api, FlutterSecureStorage? storage})
      : _api = api ?? TransactionApi(),
        _storage = storage ?? const FlutterSecureStorage();

  final TransactionApi _api;
  final List<TransactionModel> _transactions = [];

  final FlutterSecureStorage _storage;
  final List<PendingTransaction> _pending = [];
  int? _personId;
  int _session = 0;
  bool syncing = false;
  String? syncError;

  List<PendingTransaction> get pending => List.unmodifiable(_pending);
  bool get hasPendingRetry => _pending.any((item) => item.error == null);

  String _queueKey(int personId) =>
      'finnest.transaction-queue.${Env.apiBaseUrl}.$personId';

  Future<void> setSession(int personId) async {
    if (_personId == personId) return;
    clear();
    final session = _session;
    try {
      final raw = await _storage.read(key: _queueKey(personId));
      if (session != _session) return;
      final saved = raw == null ? const [] : jsonDecode(raw) as List;
      _pending.addAll(saved.map(
          (item) => PendingTransaction.fromJson(item as Map<String, dynamic>)));
      _personId = personId;
    } catch (_) {
      if (session != _session) return;
      syncError = 'Không thể mở dữ liệu giao dịch trên thiết bị.';
    }
    notifyListeners();
  }

  Future<void> _persist(
      int personId, List<PendingTransaction> items, int session) async {
    await _storage.write(key: _queueKey(personId), value: jsonEncode(items));
    if (session != _session) return;
    _pending
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  bool _retryable(DioException error) =>
      error.response == null ||
      error.response?.statusCode == 429 ||
      (error.response?.statusCode ?? 0) >= 500;

  void _remember(TransactionModel transaction) {
    _transactions
        .removeWhere((item) => item.transactionId == transaction.transactionId);
    _transactions.add(transaction);
  }

  Future<int> syncPending({bool retryRejected = false}) async {
    final personId = _personId;
    final session = _session;
    if (syncing || personId == null || _pending.isEmpty) return 0;
    syncing = true;
    syncError = null;
    notifyListeners();
    var count = 0;
    try {
      for (final item in List<PendingTransaction>.of(_pending)) {
        if (session != _session) break;
        if (item.error != null && !retryRejected) continue;
        try {
          final created = await _api.submitQueued(item.payload);
          if (session != _session) break;
          await _persist(personId,
              _pending.where((p) => p.id != item.id).toList(), session);
          if (session != _session) break;
          _remember(created);
          count++;
        } on DioException catch (error) {
          if (session != _session) break;
          if (_retryable(error) || error.response?.statusCode == 401) {
            syncError = 'Chưa thể kết nối để đồng bộ. Giao dịch vẫn được lưu.';
            break;
          }
          await _persist(
              personId,
              [
                for (final queued in _pending)
                  if (queued.id == item.id)
                    PendingTransaction(item.payload,
                        error: apiErrorMessage(error))
                  else
                    queued,
              ],
              session);
        }
      }
    } catch (_) {
      if (session == _session) {
        syncError = 'Không thể cập nhật hàng đợi trên thiết bị.';
      }
    } finally {
      syncing = false;
      notifyListeners();
    }
    return count;
  }

  Future<void> discardPending(String id) async {
    final personId = _personId;
    if (syncing || personId == null) return;
    syncing = true;
    notifyListeners();
    try {
      await _persist(
          personId, _pending.where((p) => p.id != id).toList(), _session);
    } catch (_) {
      syncError = 'Không thể xóa bản ghi trên thiết bị.';
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

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
    final session = _session;
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // Báo cáo theo ngày cần đủ lịch sử, không chỉ trang 100 giao dịch đầu.
      final items = <TransactionModel>[];
      for (var page = 0;; page++) {
        final batch = await _api.list(page: page, size: 100);
        items.addAll(batch);
        if (batch.length < 100) break;
      }
      if (session != _session) return;
      _transactions
        ..clear()
        ..addAll(items);
    } catch (e) {
      if (session == _session) errorMessage = apiErrorMessage(e);
    } finally {
      if (session == _session) {
        loading = false;
        notifyListeners();
      }
    }
  }

  /// Duyệt/từ chối giao dịch đang chờ. Trả `null` nếu thành công, ngược lại
  /// là message lỗi để screen hiển thị.
  Future<String?> decide(int transactionId, {required bool approved}) async {
    final session = _session;
    try {
      final updated = approved
          ? await _api.approve(transactionId)
          : await _api.reject(transactionId);
      if (session == _session) {
        _remember(updated);
        notifyListeners();
      }
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  /// Trả giao dịch vừa tạo, hoặc ném lỗi message để screen hiển thị.
  Future<({TransactionModel? created, String? error, bool queued})>
      addManualTransaction({
    required int financialCategoryId,
    required String content,
    required double amount,
    required TransactionType type,
  }) async {
    if (syncing) {
      return (
        created: null,
        error: 'Đang đồng bộ. Vui lòng thử lại.',
        queued: false
      );
    }
    final personId = _personId;
    if (personId == null) {
      return (
        created: null,
        error: 'Hãy tải lại hồ sơ trước khi ghi giao dịch.',
        queued: false
      );
    }
    final session = _session;
    syncing = true;
    notifyListeners();
    var savedLocally = false;
    PendingTransaction? item;
    try {
      item = PendingTransaction.create(
        personId: personId,
        categoryId: financialCategoryId,
        content: content,
        amount: amount,
        type: type,
      );
      await _persist(personId, [..._pending, item], session);
      savedLocally = true;
      if (session != _session) {
        return (
          created: null,
          error: 'Phiên đăng nhập đã thay đổi.',
          queued: false
        );
      }
      final created = await _api.submitQueued(item.payload);
      if (session != _session) {
        return (
          created: null,
          error: 'Phiên đăng nhập đã thay đổi.',
          queued: false
        );
      }
      final itemId = item.id;
      await _persist(
          personId, _pending.where((p) => p.id != itemId).toList(), session);
      if (session == _session) _remember(created);
      return (created: created, error: null, queued: false);
    } on DioException catch (error) {
      final itemId = item?.id;
      if (session != _session ||
          _retryable(error) ||
          error.response?.statusCode == 401) {
        return (created: null, error: null, queued: true);
      }
      try {
        await _persist(
            personId, _pending.where((p) => p.id != itemId).toList(), session);
      } catch (_) {
        return (created: null, error: null, queued: true);
      }
      return (created: null, error: apiErrorMessage(error), queued: false);
    } catch (_) {
      return (
        created: null,
        error: savedLocally ? null : 'Không thể lưu giao dịch trên thiết bị.',
        queued: savedLocally
      );
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  void clear() {
    _session++;
    _personId = null;
    _pending.clear();
    syncError = null;
    loading = false;
    _transactions.clear();
    errorMessage = null;
    notifyListeners();
  }
}
