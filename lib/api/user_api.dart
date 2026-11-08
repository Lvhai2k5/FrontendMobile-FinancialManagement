import 'api_client.dart';
import '../models/user_model.dart';

class UserApi {
  Future<UserModel> me() async {
    final res = await apiClient.get('/users/me');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe(
      {required String name,
      required String phone,
      required String email}) async {
    final res = await apiClient
        .put('/users/me', data: {'name': name, 'phone': phone, 'email': email});
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> createSupportTicket(String content) async {
    await apiClient.post('/support-tickets', data: {'content': content});
  }
}
