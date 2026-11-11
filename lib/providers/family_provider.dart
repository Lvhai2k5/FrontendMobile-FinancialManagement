import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/family_api.dart';
import '../models/family_model.dart';
import '../utils/api_error.dart';

/// State + logic gia đình/danh mục/hạn mức. Dữ liệu lấy từ Backend qua
/// `FamilyApi`; `screens/` chỉ đọc state và gọi hành động ở đây.
class FamilyProvider with ChangeNotifier {
  FamilyProvider({FamilyApi? api}) : _api = api ?? FamilyApi();

  final FamilyApi _api;

  final List<FamilySummaryModel> _families = [];
  final Map<int, FamilyDetailModel> _details = {};
  final Map<int, List<ThresholdModel>> _thresholds = {};
  int? _selectedFamilyId;

  int _loadVersion = 0;
  bool loading = false;
  String? errorMessage;

  List<FamilySummaryModel> get families => List.unmodifiable(_families);
  int? get selectedFamilyId => _selectedFamilyId;
  bool get hasFamily => _families.isNotEmpty;

  FamilySummaryModel? get selectedFamily {
    for (final f in _families) {
      if (f.familyId == _selectedFamilyId) return f;
    }
    return null;
  }

  FamilyDetailModel? detail(int? familyId) =>
      familyId == null ? null : _details[familyId];

  List<ThresholdModel> thresholdsOf(int categoryId) =>
      List.unmodifiable(_thresholds[categoryId] ?? const []);

  void selectFamily(int familyId) {
    if (familyId == _selectedFamilyId) return;
    _selectedFamilyId = familyId;
    notifyListeners();
  }

  /// Tải lại toàn bộ danh sách gia đình + chi tiết (hũ, thành viên, số dư).
  Future<void> load() async {
    final version = ++_loadVersion;
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final list = await _api.list();
      final resolved = await Future.wait(list.map((f) async {
        try {
          return await _api.detail(f.familyId);
        } on DioException catch (e) {
          if (e.response?.statusCode == 403 || e.response?.statusCode == 404) {
            return null;
          }
          rethrow;
        }
      }));
      if (version != _loadVersion) return;
      final details = resolved.whereType<FamilyDetailModel>();
      final availableIds = details.map((d) => d.familyId).toSet();
      _families
        ..clear()
        ..addAll(list.where((f) => availableIds.contains(f.familyId)));
      _details
        ..clear()
        ..addEntries(details.map((d) => MapEntry(d.familyId, d)));
      _thresholds.clear();
      for (final d in details) {
        for (final c in d.categories) {
          _thresholds[c.financialCategoryId] = _thresholdsFrom(c);
        }
      }
      if (_selectedFamilyId == null ||
          !_families.any((f) => f.familyId == _selectedFamilyId)) {
        _selectedFamilyId = _families.isEmpty ? null : _families.first.familyId;
      }
    } catch (e) {
      if (version == _loadVersion) errorMessage = apiErrorMessage(e);
    } finally {
      if (version == _loadVersion) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<({int? familyId, String? error})> createFamily(String name) async {
    try {
      final created = await _api.create(name);
      await load();
      if (errorMessage != null) {
        _details.putIfAbsent(created.familyId, () => created);
      }
      _selectedFamilyId = created.familyId;
      notifyListeners();
      return (familyId: created.familyId, error: null);
    } catch (e) {
      return (familyId: null, error: apiErrorMessage(e));
    }
  }

  Future<String?> joinFamily(String code) async {
    try {
      final joined = await _api.join(code);
      await load();
      _selectedFamilyId = joined.familyId;
      notifyListeners();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> addMember(int familyId, String email) =>
      _change(() => _api.addMember(familyId, email));

  Future<String?> removeMember(int familyId, int personId) =>
      _change(() => _api.removeMember(familyId, personId));

  Future<String?> updatePermissions(
          int familyId, int personId, Set<String> permissions) =>
      _change(() => _api.updatePermissions(familyId, personId, permissions));

  Future<String?> transferOwnership(int familyId, int personId) =>
      _change(() => _api.transferOwnership(familyId, personId));

  Future<String?> setCategoryLocked(int categoryId, bool locked) =>
      _change(() => _api.setCategoryLocked(categoryId, locked));

  Future<String?> _change(Future<void> Function() action) async {
    try {
      await action();
      await load();
      return errorMessage == null
          ? null
          : 'Đã lưu thay đổi. Hãy tải lại để xem dữ liệu mới.';
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<String?> createCategory(
    int familyId, {
    required String name,
    required double initialBalance,
    required double amountOfWarning,
    required double amountOfEmergency,
    required double amountOfApproval,
  }) async {
    try {
      await _api.createCategory(familyId,
          name: name,
          initialBalance: initialBalance,
          amountOfWarning: amountOfWarning,
          amountOfEmergency: amountOfEmergency,
          amountOfApproval: amountOfApproval);
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  /// Sửa tạm trên máy trong lúc người dùng chỉnh; chỉ gửi lên Backend khi
  /// gọi [saveThresholds].
  void updateThreshold(int categoryId, ThresholdType type,
      {double? amount, bool? enabled}) {
    final list = _thresholds[categoryId];
    if (list == null) return;
    final index = list.indexWhere((t) => t.type == type);
    if (index == -1) return;
    list[index] = list[index].copyWith(amount: amount, enabled: enabled);
    notifyListeners();
  }

  /// Ngưỡng bị tắt được lưu thành 0 (Backend không có cờ bật/tắt riêng).
  Future<String?> saveThresholds(int categoryId) async {
    final list = _thresholds[categoryId];
    if (list == null) return 'Không tìm thấy danh mục';
    double of(ThresholdType type) {
      final t = list.firstWhere((t) => t.type == type);
      return t.enabled ? t.amount : 0;
    }

    try {
      await _api.updateThreshold(categoryId,
          amountOfWarning: of(ThresholdType.warning),
          amountOfEmergency: of(ThresholdType.emergency),
          amountOfApproval: of(ThresholdType.approve));
      await load();
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  /// Xoá dữ liệu khi đăng xuất để tài khoản khác đăng nhập không thấy dữ liệu cũ.
  void clear() {
    _loadVersion++;
    loading = false;
    _families.clear();
    _details.clear();
    _thresholds.clear();
    _selectedFamilyId = null;
    errorMessage = null;
    notifyListeners();
  }

  List<ThresholdModel> _thresholdsFrom(FinancialCategoryModel c) => [
        ThresholdModel(
            type: ThresholdType.approve,
            amount: c.amountOfApproval,
            enabled: c.amountOfApproval > 0),
        ThresholdModel(
            type: ThresholdType.warning,
            amount: c.amountOfWarning,
            enabled: c.amountOfWarning > 0),
        ThresholdModel(
            type: ThresholdType.emergency,
            amount: c.amountOfEmergency,
            enabled: c.amountOfEmergency > 0),
      ];
}
