import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../api/vision_api.dart';
import '../models/voice_parse_result.dart';
import '../utils/api_error.dart';

/// Chụp/chọn ảnh đồ vật → nén → Backend nhận diện tên vật phẩm.
/// Kết quả chỉ là gợi ý điền form; người dùng nhập giá và xác nhận mới tạo giao dịch.
class ItemScanProvider with ChangeNotifier {
  ItemScanProvider({ImagePicker? picker, VisionApi? api})
      : _picker = picker ?? ImagePicker(),
        _api = api ?? VisionApi();

  final ImagePicker _picker;
  final VisionApi _api;

  /// Ảnh đã nén, dùng để xem lại và gửi đi.
  Uint8List? imageBytes;
  bool scanning = false;

  /// Thông báo lỗi để screen hiển thị (null khi không có lỗi).
  String? error;

  bool get canScan => imageBytes != null && !scanning;

  /// Mở camera/thư viện. Trả `true` khi người dùng đã chọn được ảnh.
  Future<bool> pick(ImageSource source) async {
    if (scanning) return false;
    error = null;
    try {
      // Nén ngay lúc chọn: giữ ảnh nhỏ để gửi nhanh và đủ cho nhận diện.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (file == null) return false;
      imageBytes = await file.readAsBytes();
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Không mở được camera hoặc thư viện ảnh. Hãy cấp quyền trong '
          'Cài đặt hoặc nhập thủ công.';
      notifyListeners();
      return false;
    }
  }

  /// Trả gợi ý điền form, hoặc null nếu lỗi (xem [error]).
  Future<VoiceParseResult?> scan(int familyId) async {
    final bytes = imageBytes;
    if (bytes == null || scanning) return null;
    scanning = true;
    error = null;
    notifyListeners();
    try {
      return await _api.scanItem(
        familyId: familyId,
        // image_picker xuất JPEG khi có imageQuality.
        mimeType: 'image/jpeg',
        imageBase64: base64Encode(bytes),
      );
    } catch (e) {
      error = apiErrorMessage(e);
      return null;
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  void clear() {
    imageBytes = null;
    error = null;
    notifyListeners();
  }
}
