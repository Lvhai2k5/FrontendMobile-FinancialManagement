import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../widgets/common/inline_picker.dart';
import '../../models/transaction_model.dart';
import '../../providers/family_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/format_currency.dart';
import '../../widgets/common/app_button.dart';

/// Gửi phản ánh & khiếu nại tới Admin — thiết kế `screen8.2`. Gửi thật qua
/// `POST /support-tickets`; Admin xử lý ở Web.
class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  static const _maxLength = 500;
  static const _otherIssue = 'Lỗi khác không liên quan giao dịch';

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final Set<int> _selectedFamilies = {};
  String? _issue;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UserProvider>().loadSupportTickets();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedFamilies.isEmpty ||
        _issue == null ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Vui lòng chọn gia đình, sự cố và nhập nội dung phản ánh.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ));
      return;
    }

    // Backend lưu 1 trường `content`, nên gộp ngữ cảnh vào đầu nội dung.
    final families = context.read<FamilyProvider>().families;
    final familyNames = families
        .where((f) => _selectedFamilies.contains(f.familyId))
        .map((f) => '${f.name} (${f.code})')
        .join(', ');
    final title = _titleController.text.trim();
    final content = [
      'Gia đình: $familyNames',
      'Sự cố: $_issue',
      if (title.isNotEmpty) 'Tiêu đề: $title',
      '',
      _contentController.text.trim(),
    ].join('\n');

    setState(() => _sending = true);
    final error = await context.read<UserProvider>().sendSupportTicket(content);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Đã gửi phản ánh tới Admin.'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error == null ? AppColors.secondary : AppColors.error,
    ));
    if (error == null) Navigator.of(context).pop();
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  Widget _label(String text, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Text(text, style: AppTypography.titleSm),
            const Spacer(),
            if (trailing != null)
              Text(trailing,
                  style:
                      AppTypography.labelSm.copyWith(color: AppColors.outline)),
          ],
        ),
      );

  String _ticketStatusLabel(Object? status) => switch (status?.toString()) {
        'SUBMITTED' => 'Đã gửi',
        'VIEWED' => 'Đang xem xét',
        'RESPONDED' => 'Đã phản hồi',
        final value when value != null && value.isNotEmpty => value,
        _ => 'Chưa rõ trạng thái',
      };

  Color _ticketStatusColor(Object? status) => switch (status?.toString()) {
        'RESPONDED' => AppColors.secondary,
        'VIEWED' => AppColors.primary,
        _ => AppColors.outline,
      };

  String _ticketDate(Object? createdAt) {
    final date = DateTime.tryParse(createdAt?.toString() ?? '')?.toLocal();
    if (date == null) return 'Thời gian chưa có';
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} · '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  String _ticketTitle(String content) {
    for (final prefix in ['Tiêu đề:', 'Sự cố:']) {
      for (final line in content.split('\n')) {
        if (line.startsWith(prefix)) {
          final value = line.substring(prefix.length).trim();
          if (value.isNotEmpty) return value;
        }
      }
    }
    final nonEmptyLines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return nonEmptyLines.isEmpty ? 'Yêu cầu hỗ trợ' : nonEmptyLines.last;
  }

  Widget _ticketStatusBadge(Object? status) {
    final color = _ticketStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _ticketStatusLabel(status),
        style: AppTypography.labelSm.copyWith(color: color),
      ),
    );
  }

  Widget _supportTicketTile(Map<String, dynamic> ticket) {
    final content = ticket['content'] as String? ?? '';
    final respondentNote = ticket['noteOfRespondent'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          _ticketTitle(content),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMd,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(_ticketDate(ticket['createdAt']),
              style: AppTypography.labelSm.copyWith(color: AppColors.outline)),
        ),
        trailing: _ticketStatusBadge(ticket['status']),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Nội dung đã gửi', style: AppTypography.labelMd),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(content, style: AppTypography.bodySm),
          ),
          if (respondentNote != null && respondentNote.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Phản hồi từ Admin', style: AppTypography.labelMd),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(respondentNote, style: AppTypography.bodySm),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final families = context.watch<FamilyProvider>().families;
    final user = context.watch<UserProvider>().user;
    final userProvider = context.watch<UserProvider>();
    final transactions = context
        .watch<TransactionProvider>()
        .transactions
        .where((t) =>
            _selectedFamilies.isEmpty || _selectedFamilies.contains(t.familyId))
        .take(30)
        .map((t) =>
            '${t.content} - ${formatCurrency(t.amount)}đ (${t.status.label})')
        .toList();
    final issues = [...transactions, _otherIssue];
    if (_issue != null && !issues.contains(_issue)) _issue = null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        title: const Text('Gửi Phản Ánh & Khiếu Nại'),
        actions: [
          IconButton(
            tooltip: 'Tải lại yêu cầu',
            onPressed: () => context.read<UserProvider>().loadSupportTickets(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.pastelBlush,
                    child: Text(
                        (user?.name ?? '').trim().isEmpty
                            ? '?'
                            : user!.name
                                .trim()
                                .split(RegExp(r'\s+'))
                                .last[0]
                                .toUpperCase(),
                        style: AppTypography.titleSm
                            .copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '...', style: AppTypography.titleSm),
                        Text(user?.email ?? '',
                            style: AppTypography.bodySm
                                .copyWith(color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              ExpansionTile(
                key: const PageStorageKey('support-tickets'),
                tilePadding: EdgeInsets.zero,
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  'Yêu cầu đã gửi (${userProvider.supportTickets.length})',
                  style: AppTypography.titleSm,
                ),
                children: [
                  if (userProvider.loadingSupportTickets)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (userProvider.supportTicketsError != null)
                    Text(userProvider.supportTicketsError!,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.error))
                  else if (userProvider.supportTickets.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Chưa có yêu cầu hỗ trợ.',
                          style: AppTypography.bodySm),
                    )
                  else
                    for (final ticket in userProvider.supportTickets)
                      _supportTicketTile(ticket),
                ],
              ),
              const Divider(height: 28),
              _label('Gia đình liên quan *'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in families)
                    FilterChip(
                      label: Text(f.name),
                      selected: _selectedFamilies.contains(f.familyId),
                      showCheckmark: true,
                      selectedColor: AppColors.pastelBlush,
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide.none,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedFamilies.add(f.familyId);
                        } else {
                          _selectedFamilies.remove(f.familyId);
                        }
                      }),
                    ),
                ],
              ),
              _label('Giao dịch hoặc nội dung gặp sự cố *'),
              InlinePicker<String>(
                placeholder: 'Chọn giao dịch/sự cố',
                value: _issue,
                options: {for (final issue in issues) issue: issue},
                onChanged: (value) => setState(() => _issue = value),
              ),
              _label('Nội dung phản ánh *',
                  trailing: '${_contentController.text.length}/$_maxLength'),
              TextField(
                controller: _titleController,
                decoration: _fieldDecoration('Tiêu đề ngắn gọn'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLength: _maxLength,
                maxLines: 5,
                decoration:
                    _fieldDecoration('Mô tả chi tiết sự cố bạn gặp phải...')
                        .copyWith(counterText: ''),
              ),
              _label('Bằng chứng đính kèm (tùy chọn)', trailing: '0/3 tệp'),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Đính kèm tệp sẽ có ở bản cập nhật tiếp theo.'),
                        behavior: SnackBarBehavior.floating)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: AppColors.pastelBlush),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.attach_file),
                label: const Text('Thêm ảnh/tệp'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Quy trình xử lý dự kiến',
                            style: AppTypography.titleSm),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final s in const [
                          '1. Tiếp nhận',
                          '2. Kiểm tra',
                          '3. Phản hồi'
                        ])
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(s, style: AppTypography.labelSm),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: _sending ? 'Đang gửi...' : 'Gửi phản ánh tới Admin',
                leadingIcon: _sending ? null : Icons.send_outlined,
                onPressed: _sending ? () {} : _submit,
              ),
              const SizedBox(height: 10),
              Center(
                child: Text('Bảo mật & mã hóa toàn trình theo chuẩn AES-256',
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.outline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
