/// Định dạng số tiền kiểu Việt Nam: `500000` → `"500.000"`. Không tự thêm
/// ký hiệu `đ`/`₫` — gọi nơi cần tự nối vào để linh hoạt (có dấu +/- trước
/// số hay không tuỳ ngữ cảnh hiển thị).
String formatCurrency(num amount) {
  final isNegative = amount < 0;
  final digits = amount.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return '${isNegative ? '-' : ''}$buffer';
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
