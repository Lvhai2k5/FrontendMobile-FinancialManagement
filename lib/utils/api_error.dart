import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Đổi lỗi gọi API thành message tiếng Việt để hiển thị — ưu tiên `message`
/// do Backend trả về (format lỗi chuẩn ở `TECH-API.md` mục 3).
String apiErrorMessage(Object error) {
  if (error is DioException) {
    if (error.response == null) return AppConstants.networkErrorMessage;
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return AppConstants.genericErrorMessage;
  }
  return AppConstants.genericErrorMessage;
}

double asDouble(Object? value) => value is num ? value.toDouble() : 0;

int asInt(Object? value) => value is num ? value.toInt() : 0;
