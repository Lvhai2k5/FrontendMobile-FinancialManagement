import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../common/app_button.dart';

/// Bottom sheet "Tùy biến" mở từ nút cùng tên trên tab Tổng quan — chọn
/// thành viên muốn xem báo cáo + kiểu biểu đồ. Theo thiết kế
/// `finnest_popup_t_y_bi_n`. Widget chỉ giữ state lựa chọn cục bộ trong
/// sheet, không có logic nghiệp vụ (áp dụng bộ lọc thật sẽ nối vào
/// `FamilyProvider` khi Backend có endpoint báo cáo theo kỳ).
class CustomizeReportSheet extends StatefulWidget {
  const CustomizeReportSheet({super.key});

  @override
  State<CustomizeReportSheet> createState() => _CustomizeReportSheetState();
}

class _CustomizeReportSheetState extends State<CustomizeReportSheet> {
  int _memberIndex = 0;
  int _chartIndex = 0;

  static const _members = ['Cả nhà', 'Minh (Chủ hộ)', 'Lan hoặc bé Bắp'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tùy biến báo cáo', style: AppTypography.headlineSm),
              const SizedBox(height: 16),
              Text('Xem báo cáo của',
                  style: AppTypography.labelMd
                      .copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_members.length, (i) {
                  final selected = i == _memberIndex;
                  return ChoiceChip(
                    label: Text(_members[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _memberIndex = i),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTypography.labelMd.copyWith(
                        color:
                            selected ? Colors.white : AppColors.onSurfaceVariant),
                    backgroundColor: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    side: BorderSide.none,
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text('Loại biểu đồ báo cáo', style: AppTypography.labelMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ChartOptionCard(
                      icon: Icons.bar_chart,
                      title: 'Cột so sánh kỳ',
                      subtitle: 'Đối chiếu xu hướng tăng giảm theo từng mốc',
                      selected: _chartIndex == 0,
                      onTap: () => setState(() => _chartIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChartOptionCard(
                      icon: Icons.pie_chart_outline,
                      title: 'Biểu đồ tròn 6 hũ',
                      subtitle: 'Phân bổ chi tiêu chi tiết theo 6 lọ tài chính',
                      selected: _chartIndex == 1,
                      onTap: () => setState(() => _chartIndex = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Áp dụng',
                trailingIcon: Icons.check,
                backgroundColor: AppColors.primaryContainer,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartOptionCard extends StatelessWidget {
  const _ChartOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.pastelBlush,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.primary),
                ),
                if (selected)
                  const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.titleSm),
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}
