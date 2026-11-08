import '../models/family_model.dart';

enum CategoryUsageStatus {
  normal('Trong ngưỡng'),
  warning('Cảnh báo'),
  emergency('Khẩn cấp'),
  depleted('Hết hạn mức'),
  locked('Đang khóa');

  const CategoryUsageStatus(this.label);
  final String label;
  bool get needsAttention => this != normal;
}

/// Ngưỡng là số tiền đã chi, 0 nghĩa là tắt. Approval áp dụng cho từng
/// giao dịch nên không tham gia trạng thái tổng sử dụng của hũ.
CategoryUsageStatus categoryUsageStatus(FinancialCategoryModel category) {
  if (category.status == CategoryStatus.locked) {
    return CategoryUsageStatus.locked;
  }
  if (category.limitAmount > 0 && category.spent >= category.limitAmount) {
    return CategoryUsageStatus.depleted;
  }
  if (category.amountOfEmergency > 0 &&
      category.spent >= category.amountOfEmergency) {
    return CategoryUsageStatus.emergency;
  }
  if (category.amountOfWarning > 0 &&
      category.spent >= category.amountOfWarning) {
    return CategoryUsageStatus.warning;
  }
  return CategoryUsageStatus.normal;
}
