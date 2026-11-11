import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../api/voice_api.dart';
import '../models/voice_parse_result.dart';
import '../utils/api_error.dart';

/// Ghi âm → STT trên thiết bị → gửi transcript cho Backend phân tích.
/// Kết quả chỉ là gợi ý điền form; người dùng xác nhận mới tạo giao dịch.
class VoiceCaptureProvider with ChangeNotifier {
  VoiceCaptureProvider({SpeechToText? speech, VoiceApi? api})
      : _speech = speech ?? SpeechToText(),
        _api = api ?? VoiceApi();

  static const _localeId = 'vi_VN';
  static const maxTranscriptLength = 500;

  final SpeechToText _speech;
  final VoiceApi _api;

  bool _initialized = false;
  bool listening = false;
  bool parsing = false;
  String transcript = '';

  /// Thông báo lỗi để screen hiển thị (null khi không có lỗi).
  String? error;

  /// `false` khi người dùng từ chối quyền mic hoặc máy không hỗ trợ STT.
  bool available = true;

  bool get canParse => !listening && !parsing && transcript.trim().isNotEmpty;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return available;
    available = await _speech.initialize(
      onError: (e) {
        // `error_no_match`/`error_speech_timeout` là bình thường khi im lặng.
        if (listening) {
          listening = false;
          if (transcript.trim().isEmpty) {
            error = 'Không nghe rõ, vui lòng thử lại ở nơi yên tĩnh hơn.';
          }
          notifyListeners();
        }
      },
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && listening) {
          listening = false;
          notifyListeners();
        }
      },
    );
    _initialized = available;
    if (!available) {
      error = 'Không dùng được micro. Hãy cấp quyền ghi âm trong Cài đặt '
          'hoặc nhập thủ công.';
    }
    return available;
  }

  Future<void> startListening() async {
    if (listening || parsing) return;
    error = null;
    if (!await _ensureInitialized()) {
      notifyListeners();
      return;
    }
    transcript = '';
    listening = true;
    notifyListeners();
    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        localeId: _localeId,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      ),
    );
  }

  void _onResult(SpeechRecognitionResult result) {
    transcript = result.recognizedWords;
    notifyListeners();
  }

  Future<void> stopListening() async {
    if (!listening) return;
    await _speech.stop();
    listening = false;
    notifyListeners();
  }

  /// Cho phép người dùng sửa lại transcript trước khi gửi (bắt lỗi STT sớm).
  void editTranscript(String value) {
    transcript = value;
    error = null;
    notifyListeners();
  }

  /// Trả gợi ý điền form, hoặc null nếu lỗi (xem [error]).
  Future<VoiceParseResult?> parse(int familyId) async {
    final text = transcript.trim();
    if (text.isEmpty || parsing) return null;
    if (text.length > maxTranscriptLength) {
      error = 'Nội dung quá dài (tối đa $maxTranscriptLength ký tự).';
      notifyListeners();
      return null;
    }
    parsing = true;
    error = null;
    notifyListeners();
    try {
      return await _api.parse(familyId: familyId, transcript: text);
    } catch (e) {
      error = apiErrorMessage(e);
      return null;
    } finally {
      parsing = false;
      notifyListeners();
    }
  }

  void reset() {
    if (listening) _speech.cancel();
    listening = false;
    parsing = false;
    transcript = '';
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
