import 'package:dio/dio.dart';

import '../models/voice_parse_result.dart';
import 'api_client.dart';

/// Gọi endpoint nhận diện đồ vật (`/api/v1/vision/scan-item`). Chỉ nhận gợi ý
/// điền form (tên vật phẩm, danh mục) — không tạo giao dịch.
class VisionApi {
  Future<VoiceParseResult> scanItem({
    required int familyId,
    required String mimeType,
    required String imageBase64,
  }) async {
    final res = await apiClient.post(
      '/vision/scan-item',
      data: {
        'familyId': familyId,
        'mimeType': mimeType,
        'imageBase64': imageBase64,
      },
      // Gửi ảnh + Gemini (kèm 1 lần thử lại): chờ lâu hơn mặc định.
      options: Options(
        sendTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return VoiceParseResult.fromJson(res.data as Map<String, dynamic>);
  }
}
