import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';
import '../constants/app_constants.dart';

/// Dio instance dùng chung toàn app — nơi duy nhất cấu hình baseURL và gắn
/// token vào header `Authorization`. Các file trong `api/` import instance
/// này, không tự tạo `Dio()` riêng.
final Dio apiClient = Dio(BaseOptions(baseUrl: Env.apiBaseUrl))
  ..interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await const FlutterSecureStorage()
          .read(key: AppConstants.accessTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
