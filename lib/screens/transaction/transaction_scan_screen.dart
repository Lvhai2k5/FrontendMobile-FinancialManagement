import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/item_scan_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_button.dart';
import 'transaction_form_screen.dart';

/// "Quét đồ vật" — chụp/chọn ảnh, Backend nhận diện tên vật phẩm rồi chuyển
/// sang form Nhập thủ công đã điền sẵn tên; người dùng chỉ cần nhập giá. Màn
/// này không bao giờ tự tạo giao dịch.
class TransactionScanScreen extends StatelessWidget {
  const TransactionScanScreen({super.key, this.familyId});

  final int? familyId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemScanProvider(),
      child: _ScanBody(familyId: familyId),
    );
  }
}

class _ScanBody extends StatelessWidget {
  const _ScanBody({required this.familyId});

  final int? familyId;

  Future<void> _pickAndScan(BuildContext context, ImageSource source) async {
    final familyId = this.familyId;
    if (familyId == null) return;
    final scan = context.read<ItemScanProvider>();
    final navigator = Navigator.of(context);
    if (!await scan.pick(source)) return;
    final result = await scan.scan(familyId);
    if (result == null) return;
    await navigator.pushReplacementNamed(
      AppRoutes.transactionFormPrefilled,
      arguments: TransactionFormArgs(familyId: familyId, prefill: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ItemScanProvider>();
    final busy = scan.scanning;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Quét đồ vật'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (familyId == null)
            const _Note(
                'Bạn chưa chọn tổ ấm. Hãy tạo hoặc chọn gia đình ở tab Gia đình trước.')
          else ...[
            Text(
              'Chụp món đồ bạn vừa mua, ứng dụng sẽ nhận diện tên. '
              'Bạn chỉ cần nhập giá.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: AppColors.surfaceContainerLow,
                  child: scan.imageBytes == null
                      ? Icon(Icons.center_focus_weak,
                          size: 64, color: AppColors.outline)
                      : Image.memory(scan.imageBytes!, fit: BoxFit.cover),
                ),
              ),
            ),
            if (scan.error != null) ...[
              const SizedBox(height: 12),
              Text(scan.error!,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 16),
            if (busy) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(
                child: Text('Đang nhận diện đồ vật...',
                    style: AppTypography.labelMd
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ),
            ] else ...[
              AppButton(
                label: 'Chụp ảnh',
                leadingIcon: Icons.photo_camera_outlined,
                backgroundColor: AppColors.primaryContainer,
                onPressed: () => _pickAndScan(context, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Chọn từ thư viện',
                leadingIcon: Icons.photo_library_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => _pickAndScan(context, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.transactionForm,
                  arguments: familyId,
                ),
                child: Text('Nhập thủ công',
                    style: AppTypography.titleSm
                        .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ],
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
