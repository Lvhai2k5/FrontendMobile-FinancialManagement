import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../utils/format_currency.dart';
import '../../widgets/common/app_button.dart';

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
                                style: AppTypography.labelSm
                                    .copyWith(color: AppColors.onSurfaceVariant)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thiết lập 3 ngưỡng kiểm soát tài chính cho hũ "${args.categoryName}".',
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ThresholdCard(
            icon: Icons.how_to_reg_outlined,
            title: 'Hạn mức cần chấp thuận',
            description:
                'Giao dịch vượt quá số tiền này cần chủ hộ phê duyệt trước khi ghi nhận.',
            amountLabel: 'Ngưỡng tiền phê duyệt mỗi lần',
            threshold: of(ThresholdType.approve),
            quickAmounts: const [500000, 1000000, 2000000, 5000000],
            footnote: 'Áp dụng cho mọi thành viên trong nhà',
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.approve, enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.approve, amount: v),
          ),
          const SizedBox(height: 16),
          _ThresholdCard(
            icon: Icons.notifications_active_outlined,
            title: 'Hạn mức cảnh báo',
            description:
                'Gửi thông báo nhắc nhở nhẹ khi chi tiêu chạm ngưỡng ngân sách đề ra.',
            amountLabel: 'Mức chi tiêu phát cảnh báo',
            threshold: of(ThresholdType.warning),
            quickAmounts: const [5000000, 10000000, 15000000, 20000000],
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.warning, enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.warning, amount: v),
          ),
          const SizedBox(height: 16),
          _ThresholdCard(
            icon: Icons.lock_clock_outlined,
            title: 'Hạn mức khẩn cấp',
            description:
                'Tự động khoá tạm thời danh mục chi tiêu khi số dư chạm mức báo động để bảo toàn quỹ.',
            amountLabel: 'Ngưỡng kích hoạt phong toả',
            threshold: of(ThresholdType.emergency),
            quickAmounts: const [1000000, 2000000, 3000000, 5000000],
            editable: isOwner,
            onToggle: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.emergency, enabled: v),
            onAmountChanged: (v) => provider.updateThreshold(
                args.categoryId, ThresholdType.emergency, amount: v),
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
                    'Lưu ý: Chỉ chủ hộ mới có quyền thay đổi các ngưỡng bảo vệ này. Các thành viên khác sẽ nhận thông báo khi có điều chỉnh.',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Lưu cấu hình',
            leadingIcon: Icons.check,
            backgroundColor: AppColors.primaryContainer,
            onPressed: isOwner
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã lưu cấu hình hạn mức.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                    Navigator.of(context).maybePop();
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chỉ chủ hộ mới được sửa cấu hình này.'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
          ),
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
    required this.quickAmounts,
    required this.editable,
    required this.onToggle,
    required this.onAmountChanged,
    this.footnote,
  });

  final IconData icon;
  final String title;
  final String description;
  final String amountLabel;
  final ThresholdModel threshold;
  final List<double> quickAmounts;
  final bool editable;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onAmountChanged;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final enabled = threshold.enabled;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
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
                    Text(title, style: AppTypography.titleSm),
                    const SizedBox(height: 2),
                    Text(description,
                        style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
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
            const SizedBox(height: 12),
            Text(amountLabel,
                style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('đ', style: AppTypography.titleSm.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 8),
                  Text(formatCurrency(threshold.amount), style: AppTypography.titleSm),
                  const Spacer(),
                  Text('VNĐ', style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amount in quickAmounts)
                  GestureDetector(
                    onTap: editable ? () => onAmountChanged(amount) : null,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: threshold.amount == amount
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('+${_shortLabel(amount)}',
                          style: AppTypography.labelSm.copyWith(
                              color: threshold.amount == amount
                                  ? Colors.white
                                  : AppColors.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
            if (footnote != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.groups_outlined, size: 14, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Text(footnote!,
                      style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
                ],
              ),
            ],
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text('Đã tắt — bật công tắc để chỉnh sửa',
                    style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _shortLabel(double amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}tr';
    }
    return '${(amount / 1000).round()}k';
  }
}
