import 'package:flutter/services.dart';

/// Định dạng số tiền kiểu Việt Nam: `500000` → `"500.000"`. Không tự thêm
/// ký hiệu `đ`/`₫` — gọi nơi cần tự nối vào để linh hoạt (có dấu +/- trước
/// số hay không tuỳ ngữ cảnh hiển thị).
String formatCurrency(num amount) {
  final isNegative = amount < 0;
  final digits = _groupDigits(amount.abs().round().toString());
  return '${isNegative ? '-' : ''}$digits';
}

String _groupDigits(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

double? parseCurrencyInput(String value) =>
    double.tryParse(value.replaceAll('.', ''));

/// Nhóm chữ số khi nhập VND và giữ con trỏ tại vị trí tương ứng.
class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter();

  static final _nonDigits = RegExp(r'[^0-9]');
  static final _invalidCharacters = RegExp(r'[^0-9.,\s]');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (_invalidCharacters.hasMatch(raw)) return oldValue;
    final text = _groupDigits(raw.replaceAll(_nonDigits, ''));
    if (!newValue.selection.isValid) return TextEditingValue(text: text);

    int offset(int rawOffset) {
      var digits =
          raw.substring(0, rawOffset).replaceAll(_nonDigits, '').length;
      var index = 0;
      while (digits > 0) {
        if (text[index] != '.') digits--;
        index++;
      }
      return index;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: offset(newValue.selection.baseOffset),
        extentOffset: offset(newValue.selection.extentOffset),
      ),
    );
  }
}

/// Số rút gọn để đọc nhanh; số đầy đủ vẫn được giữ cho phần chi tiết.
String formatCompactCurrency(num amount) {
  final absolute = amount.abs();
  if (absolute < 1000) return '${formatCurrency(amount)} đ';
  final divisor = absolute >= 1000000000
      ? 1000000000
      : absolute >= 1000000
          ? 1000000
          : 1000;
  final unit = divisor == 1000000000
      ? 'tỷ'
      : divisor == 1000000
          ? 'triệu'
          : 'nghìn';
  final value = (amount / divisor)
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '')
      .replaceAll('.', ',');
  return '$value $unit đ';
}
