import 'api_client.dart';
import '../models/family_model.dart';

/// Gọi endpoint gia đình/danh mục tài chính (`/api/v1/families`,
/// `/api/v1/financial-categories`). Chỉ gửi/nhận JSON, không giữ state.
class FamilyApi {
  Future<List<FamilySummaryModel>> list() async {
    final res = await apiClient.get('/families');
    return (res.data as List)
        .map((e) => FamilySummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FamilyDetailModel> detail(int familyId) async {
    final res = await apiClient.get('/families/$familyId');
    return FamilyDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<FamilyDetailModel> create(String name) async {
    final res = await apiClient.post('/families', data: {'name': name});
    return FamilyDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<FamilyDetailModel> join(String code) async {
    final res = await apiClient.post('/families/join', data: {'code': code});
    return FamilyDetailModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> createCategory(
    int familyId, {
    required String name,
    required double initialBalance,
    required double amountOfWarning,
    required double amountOfEmergency,
    required double amountOfApproval,
  }) async {
    await apiClient.post('/families/$familyId/financial-categories', data: {
      'name': name,
      'initialBalance': initialBalance,
      'amountOfWarning': amountOfWarning,
      'amountOfEmergency': amountOfEmergency,
      'amountOfApproval': amountOfApproval,
    });
  }

  Future<void> updateThreshold(
    int categoryId, {
    required double amountOfWarning,
    required double amountOfEmergency,
    required double amountOfApproval,
  }) async {
    await apiClient.put('/financial-categories/$categoryId/thresholds', data: {
      'amountOfWarning': amountOfWarning,
      'amountOfEmergency': amountOfEmergency,
      'amountOfApproval': amountOfApproval,
    });
  }
}
