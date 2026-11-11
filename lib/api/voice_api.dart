import 'package:dio/dio.dart';

import '../models/voice_parse_result.dart';
import 'api_client.dart';

/// Gọi endpoint ghi chi tiêu bằng giọng nói (`/api/v1/voice`). Chỉ nhận gợi ý
/// điền form — không tạo giao dịch.
class VoiceApi {
  Future<VoiceParseResult> parse({
    required int familyId,
    required String transcript,
  }) async {
    final res = await apiClient.post(
      '/voice/parse',
      data: {'familyId': familyId, 'transcript': transcript},
      // Gemini có thể mất vài giây (kèm 1 lần thử lại): chờ lâu hơn mặc định 20s.
      options: Options(receiveTimeout: const Duration(seconds: 45)),
    );
    return VoiceParseResult.fromJson(res.data as Map<String, dynamic>);
  }
}
