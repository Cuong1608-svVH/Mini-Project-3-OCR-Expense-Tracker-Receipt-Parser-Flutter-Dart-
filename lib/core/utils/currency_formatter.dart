import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,###', 'vi_VN');

  /// Định dạng số tiền kèm ký hiệu ₫ (ví dụ: 150.000 ₫)
  static String formatVnd(num amount) {
    return _vndFormat.format(amount).trim();
  }

  /// Định dạng số tiền thuần không kèm ký hiệu (ví dụ: 150.000)
  static String formatNumber(num amount) {
    return _numberFormat.format(amount);
  }

  /// Parse chuỗi số thành double (hỗ trợ cả dấu chấm và dấu phẩy phân cách)
  static double parseAmount(String input) {
    if (input.isEmpty) return 0.0;
    // Bỏ ký hiệu tiền tệ và khoảng trắng
    String cleaned = input.replaceAll(RegExp(r'[^\d,.]'), '').trim();
    if (cleaned.isEmpty) return 0.0;

    // Nếu có cả dấu chấm và dấu phẩy (ví dụ: 1.250,50 hoặc 1,250.50)
    if (cleaned.contains('.') && cleaned.contains(',')) {
      int lastDot = cleaned.lastIndexOf('.');
      int lastComma = cleaned.lastIndexOf(',');
      if (lastDot > lastComma) {
        // Kiểu chuẩn Mỹ: 1,250.50
        cleaned = cleaned.replaceAll(',', '');
      } else {
        // Kiểu chuẩn Việt/Âu: 1.250,50
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (cleaned.contains('.')) {
      // Ví dụ: 150.000 (thường là phân cách nghìn ở VN)
      List<String> parts = cleaned.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        // Là phân cách hàng nghìn
        cleaned = cleaned.replaceAll('.', '');
      }
    } else if (cleaned.contains(',')) {
      List<String> parts = cleaned.split(',');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
        // Là phân cách hàng nghìn
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '.');
      }
    }

    return double.tryParse(cleaned) ?? 0.0;
  }
}
