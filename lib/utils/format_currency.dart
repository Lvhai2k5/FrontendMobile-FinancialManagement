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
