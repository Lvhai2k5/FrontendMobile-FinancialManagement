import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/voice_capture_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import 'transaction_form_screen.dart';

/// "Ghi âm giọng nói" — nói câu chi tiêu, xem/sửa lại văn bản nhận diện, rồi
/// chuyển sang form Nhập thủ công đã điền sẵn để xác nhận. Màn này không
/// bao giờ tự tạo giao dịch.
class TransactionVoiceScreen extends StatelessWidget {
  const TransactionVoiceScreen({super.key, this.familyId});

  final int? familyId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceCaptureProvider(),
      child: _VoiceBody(familyId: familyId),
    );
  }
}

class _VoiceBody extends StatefulWidget {
  const _VoiceBody({required this.familyId});

  final int? familyId;

  @override
  State<_VoiceBody> createState() => _VoiceBodyState();
}

class _VoiceBodyState extends State<_VoiceBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncController(String text) {
    if (_controller.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _handleParse() async {
    final familyId = widget.familyId;
    if (familyId == null) return;
    final voice = context.read<VoiceCaptureProvider>();
    final result = await voice.parse(familyId);
    if (!mounted || result == null) return;
    await Navigator.of(context).pushReplacementNamed(
      AppRoutes.transactionFormPrefilled,
      arguments: TransactionFormArgs(familyId: familyId, prefill: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voice = context.watch<VoiceCaptureProvider>();
    // Chỉ ghi đè ô văn bản khi STT đang đưa chữ về; lúc người dùng gõ sửa thì giữ nguyên.
    if (voice.listening) _syncController(voice.transcript);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Ghi âm giọng nói'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (widget.familyId == null)
            const _Note(
                'Bạn chưa chọn tổ ấm. Hãy tạo hoặc chọn gia đình ở tab Gia đình trước.')
          else ...[
            Text(
              'Nhấn micro rồi nói, ví dụ: "chi 50 nghìn tiền cà phê".',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Center(
              child: _MicButton(
                listening: voice.listening,
                enabled: !voice.parsing,
                onTap: voice.listening
                    ? voice.stopListening
                    : voice.startListening,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                voice.listening ? 'Đang nghe... nhấn để dừng' : 'Nhấn để nói',
                style: AppTypography.labelMd
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            Text('Văn bản nhận diện',
                style: AppTypography.titleSm
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              enabled: !voice.listening && !voice.parsing,
              minLines: 3,
              maxLines: 5,
              maxLength: VoiceCaptureProvider.maxTranscriptLength,
              onChanged: voice.editTranscript,
              decoration: InputDecoration(
                hintText: 'Văn bản sẽ hiện ở đây, bạn có thể sửa lại cho đúng.',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (voice.error != null) ...[
              const SizedBox(height: 8),
              Text(voice.error!,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 16),
            if (voice.parsing)
              const Center(child: CircularProgressIndicator())
            else
              AppButton(
                label: 'Phân tích và điền form',
                trailingIcon: Icons.arrow_forward,
                backgroundColor: AppColors.primaryContainer,
                onPressed: () {
                  if (voice.canParse) _handleParse();
                },
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: voice.parsing
                  ? null
                  : () => Navigator.of(context).pushReplacementNamed(
                        AppRoutes.transactionForm,
                        arguments: widget.familyId,
                      ),
              child: const Text('Nhập thủ công'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton(
      {required this.listening, required this.enabled, required this.onTap});

  final bool listening;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: listening ? 'Dừng ghi âm' : 'Bắt đầu ghi âm',
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: 56,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: listening ? AppColors.error : AppColors.primaryContainer,
          ),
          child: Icon(listening ? Icons.stop : Icons.mic,
              size: 40, color: Colors.white),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style:
              AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
    );
  }
}
