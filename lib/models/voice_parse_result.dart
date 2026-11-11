import '../utils/api_error.dart';
import 'transaction_model.dart';

/// Gợi ý điền form từ câu nói — khớp `VoiceResponses.Parsed` của Backend.
/// Mọi trường ngoài `type` có thể null: để trống cho người dùng tự nhập,
/// không đoán bừa.
class VoiceParseResult {
  const VoiceParseResult({
    required this.type,
    this.amount,
    this.content,
    this.categoryId,
    this.categoryName,
  });

  final TransactionType type;
  final double? amount;
  final String? content;
  final int? categoryId;
  final String? categoryName;

  factory VoiceParseResult.fromJson(Map<String, dynamic> json) =>
      VoiceParseResult(
        type: json['transactionType'] == 'INCOME'
            ? TransactionType.income
            : TransactionType.expense,
        amount: json['amount'] == null ? null : asDouble(json['amount']),
        content: json['content'] as String?,
        categoryId: json['financialCategoryId'] == null
            ? null
            : asInt(json['financialCategoryId']),
        categoryName: json['categoryName'] as String?,
      );
}
