import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';
import '../constants/app_constants.dart';

const _storage = FlutterSecureStorage();

/// Được gán ở `main.dart`: gọi khi refresh token cũng hết hạn để đưa người
/// dùng về màn đăng nhập (api/ không được import ngược từ routes/screens).
void Function()? onSessionExpired;

/// Dio instance dùng chung toàn app — nơi duy nhất cấu hình baseURL, gắn
/// token vào header `Authorization` và tự refresh khi gặp `401` (xem
/// `TECH-AUTH.md`). Các file trong `api/` import instance này.
final Dio apiClient = _createClient();

Dio _createClient() {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      if (token != null && !options.path.startsWith('/auth/')) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      final request = error.requestOptions;
      final isAuthCall = request.path.startsWith('/auth/');
      final alreadyRetried = request.extra['retried'] == true;
      if (error.response?.statusCode != 401 || isAuthCall || alreadyRetried) {
        return handler.next(error);
      }

      final refreshed = await _refreshTokens();
      if (!refreshed) {
        await _storage.delete(key: AppConstants.accessTokenKey);
        await _storage.delete(key: AppConstants.refreshTokenKey);
        onSessionExpired?.call();
        return handler.next(error);
      }

      try {
        final token = await _storage.read(key: AppConstants.accessTokenKey);
        request.headers['Authorization'] = 'Bearer $token';
        request.extra['retried'] = true;
        handler.resolve(await dio.fetch(request));
      } on DioException catch (e) {
        handler.next(e);
      }
    },
  ));
  return dio;
}

/// Đổi refresh token lấy cặp token mới; dùng Dio riêng để không vòng lặp
/// qua interceptor ở trên.
Future<bool> _refreshTokens() async {
  final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
  if (refreshToken == null) return false;
  try {
    final res = await Dio(BaseOptions(baseUrl: Env.apiBaseUrl))
        .post('/auth/refresh', data: {'refreshToken': refreshToken});
    final data = res.data as Map<String, dynamic>;
    await _storage.write(
        key: AppConstants.accessTokenKey, value: data['accessToken'] as String);
    await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: data['refreshToken'] as String);
    return true;
  } on DioException {
    return false;
  }
}
