import 'api_client.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class UserApi {
  Future<UserModel> me() async {
    final res = await apiClient.get('/users/me');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe(
      {required String name, required String phone}) async {
    final res =
        await apiClient.put('/users/me', data: {'name': name, 'phone': phone});
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> uploadAvatar(String path, String fileName) async {
    final extension = fileName.toLowerCase().split('.').last;
    final subtype = switch (extension) {
      'png' => 'png',
      'webp' => 'webp',
      'gif' => 'gif',
      'heic' || 'heif' => 'heic',
      _ => 'jpeg',
    };
    final res = await apiClient.post('/users/me/avatar',
        data: FormData.fromMap({
          'avatar': await MultipartFile.fromFile(path,
              filename: fileName, contentType: DioMediaType('image', subtype)),
        }));
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await apiClient.put('/users/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> createSupportTicket(String content) async {
    await apiClient.post('/support-tickets', data: {'content': content});
  }

  Future<List<Map<String, dynamic>>> mySupportTickets() async {
    final res = await apiClient.get('/support-tickets');
    return (res.data as List).cast<Map<String, dynamic>>();
  }
}
