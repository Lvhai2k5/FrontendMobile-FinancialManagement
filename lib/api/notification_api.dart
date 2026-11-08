import 'api_client.dart';
import '../models/notification_model.dart';

class NotificationApi {
  Future<List<NotificationModel>> list() async {
    final res = await apiClient.get('/notifications');
    return (res.data as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
