import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../utils/format_currency.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/text_input_dialog.dart';

class ThresholdConfigArgs {
  const ThresholdConfigArgs({
    required this.familyName,
    required this.myRole,
    required this.categoryId,
    required this.categoryName,
  });

  final String familyName;
  final MemberRole myRole;
  final int categoryId;
  final String categoryName;
}

/// Cấu hình 3 `Threshold` (Approve/Warning/Emergency) của 1
/// `FinancialCategory` — chỉ Chủ hộ (Owner) mới sửa được, theo mục 3.3
/// `BUSINESS-REQUIREMENTS.md`. Thiết kế theo `c_u_h_nh_h_n_m_c_finnest`.
class ThresholdConfigScreen extends StatelessWidget {
  const ThresholdConfigScreen({super.key, required this.args});

  final ThresholdConfigArgs args;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FamilyProvider>();
    final thresholds = provider.thresholdsOf(args.categoryId);
    final isOwner = args.myRole == MemberRole.owner;
    if (thresholds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cấu hình hạn mức')),
        body: const Center(child: Text('Danh mục không còn khả dụng.')),
      );
    }

    ThresholdModel of(ThresholdType type) =>
        thresholds.firstWhere((t) => t.type == type);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Cấu hình hạn mức'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pastelBlush.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pastelPeach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Text(args.familyName,
                                  style: AppTypography.titleSm,
                                  overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(args.myRole.label,
                                style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thiết lập 3 ngưỡng kiểm soát tài chính cho danh mục "${args.categoryName}".',
                        style: AppTypography.labelSm
                            .copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ThresholdCard(
            icon: Icons.how_to_reg_outlined,
            title: 'Hạn mức cần chấp thuận',
            description:
                'Khoản chi của thành viên từ mức này sẽ chờ người có quyền Duyệt.',
            amountLabel: 'Ngưỡng tiền phê duyệt mỗi lần',
            threshold: of(ThresholdType.approve),
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.approve,
                enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.approve,
                amount: v),
          ),
          const SizedBox(height: 20),
          _ThresholdCard(
            icon: Icons.notifications_active_outlined,
            title: 'Hạn mức cảnh báo',
            description:
                'Gửi thông báo nhắc nhở nhẹ khi chi tiêu chạm ngưỡng ngân sách đề ra.',
            amountLabel: 'Mức chi tiêu phát cảnh báo',
            threshold: of(ThresholdType.warning),
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.warning,
                enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.warning,
                amount: v),
          ),
          const SizedBox(height: 20),
          _ThresholdCard(
            icon: Icons.lock_clock_outlined,
            title: 'Hạn mức khẩn cấp',
            description:
                'Danh mục tự khóa khi tổng chi đã duyệt chạm ngưỡng này.',
            amountLabel: 'Ngưỡng kích hoạt phong toả',
            threshold: of(ThresholdType.emergency),
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.emergency,
                enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.emergency,
                amount: v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOwner
                        ? 'Lưu ý: Chủ hộ có thể chỉnh các ngưỡng bảo vệ cho từng danh mục.'
                        : 'Bạn chỉ có quyền xem. Chỉ chủ hộ mới được chỉnh cấu hình hạn mức.',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isOwner)
            AppButton(
                label: 'Lưu cấu hình',
                leadingIcon: Icons.check,
                backgroundColor: AppColors.primaryContainer,
                onPressed: () async {
                  final error = await provider.saveThresholds(args.categoryId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Đã lưu cấu hình hạn mức.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor:
                          error == null ? AppColors.secondary : AppColors.error,
                    ),
                  );
                  if (error == null) Navigator.of(context).maybePop();
                }),
        ],
      ),
    );
  }
}

class _ThresholdCard extends StatelessWidget {
  const _ThresholdCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.amountLabel,
    required this.threshold,
    required this.editable,
    required this.onToggle,
    required this.onAmountChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final String amountLabel;
  final ThresholdModel threshold;
  final bool editable;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = threshold.enabled;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.outline.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.titleSm.copyWith(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: AppTypography.bodyMd.copyWith(
                            fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: editable ? onToggle : null,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            Divider(
                height: 1,
                thickness: 1,
                color: AppColors.outline.withValues(alpha: 0.25)),
            const SizedBox(height: 16),
            Text(amountLabel,
                style: AppTypography.bodyMd.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: 10),
            InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: editable
                    ? () async {
                        final value = await showTextInputDialog(
                          context,
                          title: amountLabel,
                          hint: 'Nhập số tiền (đ)',
                          keyboardType: TextInputType.number,
                          initialValue: formatCurrency(threshold.amount),
                          inputFormatters: const [CurrencyInputFormatter()],
                        );
                        final parsed = parseCurrencyInput(value ?? '');
                        if (parsed != null && parsed >= 0) {
                          onAmountChanged(parsed);
                        }
                      }
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Text('đ',
                          style: AppTypography.titleSm
                              .copyWith(color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text(formatCurrency(threshold.amount),
                          style: AppTypography.titleSm.copyWith(fontSize: 18)),
                      const Spacer(),
                      Text('VNĐ',
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.outline)),
                    ],
                  ),
                )),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text('Đã tắt — bật công tắc để chỉnh sửa',
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
