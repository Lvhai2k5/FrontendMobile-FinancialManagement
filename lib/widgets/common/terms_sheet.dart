import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Hiện sheet "Điều khoản & Chính sách" (thiết kế `screen2.1`).
/// Trả về `true` nếu người dùng bấm "Tôi đã hiểu & Đồng ý".
Future<bool?> showTermsSheet(BuildContext context,
    {bool showPrivacy = false, bool readOnly = false}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TermsSheet(showPrivacy: showPrivacy, readOnly: readOnly),
  );
}

class _TermsSheet extends StatefulWidget {
  const _TermsSheet({required this.showPrivacy, required this.readOnly});
  final bool showPrivacy;
  final bool readOnly;

  @override
  State<_TermsSheet> createState() => _TermsSheetState();
}

class _TermsSheetState extends State<_TermsSheet> {
  late bool _showTerms = !widget.showPrivacy;

  static const _terms = <(String, String)>[
    (
      'Nguyên tắc quản trị tổ ấm & Tài khoản',
      'FinNest phân định rõ quyền hạn giữa Chủ hộ (phân bổ quỹ gia đình, thiết lập 6 hũ chi tiêu, duyệt định mức) và Thành viên (nhập hóa đơn hàng ngày, gửi yêu cầu chi). Mọi thành viên cam kết dữ liệu thu chi ghi chép trung thực phục vụ lợi ích chung của gia đình.'
    ),
    (
      'Bảo mật dữ liệu tài chính đa tầng',
      'Dữ liệu giao dịch, số dư quỹ và ảnh chụp biên lai qua công nghệ AI OCR được mã hóa chuẩn cao cấp AES-256. FinNest trang bị khóa hạn mức an toàn dành cho tài khoản con trẻ và tính năng xác thực sinh trắc học cá nhân.'
    ),
    (
      'Quyền riêng tư & Cam kết không bán dữ liệu',
      'Chúng tôi kiên định tôn trọng sự riêng tư: tuyệt đối không bán hay chia sẻ thông tin tiêu dùng nội bộ của gia đình bạn cho bất kỳ đơn vị quảng cáo hay bên thứ ba nào. Bạn có toàn quyền xuất báo cáo tài chính sao kê hoặc yêu cầu xóa dữ liệu vĩnh viễn.'
    ),
  ];

  static const _privacy = <(String, String)>[
    (
      'Dữ liệu chúng tôi thu thập',
      'Họ tên, email, số điện thoại và các giao dịch thu chi do bạn tự nhập hoặc quét hóa đơn. Không thu thập danh bạ hay vị trí.'
    ),
    (
      'Mục đích sử dụng',
      'Chỉ dùng để tổng hợp báo cáo, cảnh báo hạn mức và đồng bộ giữa các thành viên trong cùng tổ ấm.'
    ),
    (
      'Quyền của bạn',
      'Bạn có thể xem, chỉnh sửa, xuất hoặc yêu cầu xóa vĩnh viễn dữ liệu cá nhân bất cứ lúc nào qua mục Gửi phản ánh.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _showTerms ? _terms : _privacy;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Điều khoản & Chính sách',
                          style: IntroTypography.heading.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      Text('Cập nhật lần cuối: Tháng 10/2024',
                          style: IntroTypography.small
                              .copyWith(color: AppColors.outline)),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainer),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _tab('Điều khoản dịch vụ', Icons.description_outlined, true),
                  _tab('Chính sách bảo mật', Icons.shield_outlined, false),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_work_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chào mừng bạn đến với FinNest - Nền tảng quản trị tài chính gia đình ấm áp, văn minh và minh bạch dành riêng cho tổ ấm Việt.',
                          style: IntroTypography.small
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < items.length; i++) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.pastelBlush,
                        child: Text('${i + 1}',
                            style: IntroTypography.caption
                                .copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              Text(items[i].$1, style: IntroTypography.title)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 34, bottom: 16),
                    child: Text(items[i].$2,
                        style: IntroTypography.body
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: AppColors.surfaceContainerLow,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (!widget.readOnly)
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              'Bằng việc tiếp tục, bạn đồng ý với các quy định bảo vệ tổ ấm của FinNest.',
                              style: IntroTypography.caption
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  if (!widget.readOnly) const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pop(!widget.readOnly),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            textStyle:
                                IntroTypography.title.copyWith(height: 1.25),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999)),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(widget.readOnly
                              ? 'Đã hiểu'
                              : 'Tôi đã hiểu & Đồng ý'),
                        ),
                      ),
                      if (!widget.readOnly)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Đóng lại',
                              style: IntroTypography.label
                                  .copyWith(color: AppColors.onSurfaceVariant)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, IconData icon, bool isTerms) {
    final selected = _showTerms == isTerms;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showTerms = isTerms),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppColors.primary : AppColors.outline),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: IntroTypography.label.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
