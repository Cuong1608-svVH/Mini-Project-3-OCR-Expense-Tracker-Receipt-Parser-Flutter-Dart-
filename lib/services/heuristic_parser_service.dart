import '../models/category_item.dart';
import '../models/parsed_receipt.dart';

class HeuristicParserService {
  /// Hàm chính để phân tích văn bản OCR từ hóa đơn
  static ParsedReceipt parse(String ocrText) {
    if (ocrText.trim().isEmpty) {
      return const ParsedReceipt(
        rawLines: [],
        rawText: '',
        confidenceScore: 0.0,
      );
    }

    final List<String> rawLines = ocrText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final merchant = _extractMerchant(rawLines);
    final date = _extractDate(rawLines);
    final totalAmount = _extractTotalAmount(rawLines);
    final suggestedCategory = _suggestCategory(merchant, rawLines);

    // Tính điểm tin cậy tổng thể (0.0 đến 1.0)
    double confidence = 0.2;
    if (totalAmount != null && totalAmount > 0) confidence += 0.4;
    if (merchant != null && merchant.isNotEmpty) confidence += 0.2;
    if (date != null) confidence += 0.2;

    return ParsedReceipt(
      merchant: merchant,
      date: date,
      totalAmount: totalAmount,
      suggestedCategoryId: suggestedCategory.id,
      suggestedCategoryName: suggestedCategory.name,
      rawLines: rawLines,
      rawText: ocrText,
      confidenceScore: confidence.clamp(0.0, 1.0),
    );
  }

  /// Trích xuất tên điểm bán / cửa hàng từ các dòng đầu của hóa đơn
  static String? _extractMerchant(List<String> lines) {
    if (lines.isEmpty) return null;

    // Danh sách thương hiệu phổ biến tại Việt Nam để ưu tiên khớp
    final knownBrands = [
      'WinMart+',
      'WinMart',
      'Circle K',
      'Highlands Coffee',
      'Highlands',
      'Phúc Long',
      'The Coffee House',
      'Katinat',
      'Starbucks',
      'Bách Hóa Xanh',
      'Co.opmart',
      'Lotte Mart',
      'King BBQ',
      'Golden Gate',
      'KFC',
      'Lotteria',
      'Jollibee',
      'Pizza 4P\'s',
      'Texas Chicken',
      'Grab',
      'Be',
      'Pharmacity',
      'Long Châu',
      'An Khang',
      'CGV',
      'Lotte Cinema',
      'Petrolimex',
      'Ministop',
      '7-Eleven',
      'FamilyMart',
      'GS25',
    ];

    // 1. Kiểm tra xem có xuất hiện tên thương hiệu phổ biến trong toàn bộ text đầu
    for (int i = 0; i < lines.length && i < 8; i++) {
      final line = lines[i];
      for (final brand in knownBrands) {
        if (line.toLowerCase().contains(brand.toLowerCase())) {
          return brand;
        }
      }
    }

    // 2. Lọc bỏ các dòng tiêu đề chung, mã số thuế, địa chỉ
    final noiseRegex = RegExp(
      r'^(hóa đơn|phiếu thanh toán|phiếu thu|phiếu tạm tính|receipt|invoice|bill|vat|cộng hòa|độc lập|cửa hàng số|chi nhánh|mst|mã số thuế|địa chỉ|tel|hotline|ngày|bàn số|thu ngân|stt)',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length && i < 6; i++) {
      final line = lines[i];
      if (line.length >= 3 && line.length <= 60 && !noiseRegex.hasMatch(line)) {
        // Loại bỏ ký tự đặc biệt ở đầu hoặc đuôi
        final cleaned = line.replaceAll(RegExp(r'^[^a-zA-Z0-9À-ỹ]+|[^a-zA-Z0-9À-ỹ]+$'), '');
        if (cleaned.isNotEmpty) {
          return cleaned;
        }
      }
    }

    return lines.isNotEmpty ? lines.first : 'Hóa đơn chi tiêu';
  }

  /// Trích xuất ngày giờ giao dịch
  static DateTime? _extractDate(List<String> lines) {
    DateTime? foundDate;
    int hour = 12;
    int minute = 0;

    // Pattern 1: Ngày ... tháng ... năm ...
    final textDatePattern = RegExp(
      r'ngày\s*(\d{1,2})\s*tháng\s*(\d{1,2})\s*năm\s*(\d{4})',
      caseSensitive: false,
    );

    // Pattern 2: DD/MM/YYYY hoặc DD-MM-YYYY hoặc DD.MM.YYYY
    final dmyPattern = RegExp(
      r'(?:ngày|date|time)?[:\s]*(\d{1,2})[\/\.-](\d{1,2})[\/\.-](\d{4})',
      caseSensitive: false,
    );

    // Pattern 3: YYYY-MM-DD
    final ymdPattern = RegExp(
      r'(\d{4})[\/\.-](\d{1,2})[\/\.-](\d{1,2})',
    );

    // Pattern 4: DD/MM/YY (năm 2 chữ số)
    final dmyShortPattern = RegExp(
      r'(\d{1,2})[\/\.-](\d{1,2})[\/\.-](\d{2})(?!\d)',
    );

    // Pattern Time: HH:mm hoặc HH:mm:ss
    final timePattern = RegExp(
      r'(\d{1,2}):(\d{2})(?::\d{2})?',
    );

    for (final line in lines) {
      // Tìm giờ phút
      final timeMatch = timePattern.firstMatch(line);
      if (timeMatch != null) {
        final h = int.tryParse(timeMatch.group(1) ?? '');
        final m = int.tryParse(timeMatch.group(2) ?? '');
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          hour = h;
          minute = m;
        }
      }

      // Pattern 1
      final m1 = textDatePattern.firstMatch(line);
      if (m1 != null) {
        final d = int.tryParse(m1.group(1) ?? '');
        final m = int.tryParse(m1.group(2) ?? '');
        final y = int.tryParse(m1.group(3) ?? '');
        if (d != null && m != null && y != null && _isValidDate(y, m, d)) {
          foundDate = DateTime(y, m, d, hour, minute);
          break;
        }
      }

      // Pattern 2
      final m2 = dmyPattern.firstMatch(line);
      if (m2 != null) {
        final d = int.tryParse(m2.group(1) ?? '');
        final m = int.tryParse(m2.group(2) ?? '');
        final y = int.tryParse(m2.group(3) ?? '');
        if (d != null && m != null && y != null && _isValidDate(y, m, d)) {
          foundDate = DateTime(y, m, d, hour, minute);
          break;
        }
      }

      // Pattern 3
      final m3 = ymdPattern.firstMatch(line);
      if (m3 != null) {
        final y = int.tryParse(m3.group(1) ?? '');
        final m = int.tryParse(m3.group(2) ?? '');
        final d = int.tryParse(m3.group(3) ?? '');
        if (d != null && m != null && y != null && _isValidDate(y, m, d)) {
          foundDate = DateTime(y, m, d, hour, minute);
          break;
        }
      }

      // Pattern 4
      final m4 = dmyShortPattern.firstMatch(line);
      if (m4 != null && foundDate == null) {
        final d = int.tryParse(m4.group(1) ?? '');
        final m = int.tryParse(m4.group(2) ?? '');
        final yy = int.tryParse(m4.group(3) ?? '');
        if (d != null && m != null && yy != null) {
          final y = 2000 + yy;
          if (_isValidDate(y, m, d)) {
            foundDate = DateTime(y, m, d, hour, minute);
          }
        }
      }
    }

    return foundDate ?? DateTime.now();
  }

  static bool _isValidDate(int y, int m, int d) {
    if (y < 2000 || y > 2035) return false;
    if (m < 1 || m > 12) return false;
    if (d < 1 || d > 31) return false;
    return true;
  }

  /// Trích xuất tổng tiền thanh toán từ hóa đơn
  static double? _extractTotalAmount(List<String> lines) {
    final totalKeywords = [
      'tiền cần thanh toán',
      'tien can thanh toan',
      'cần thanh toán',
      'can thanh toan',
      'tiền thanh toán',
      'thanh toan',
      'tổng tiền',
      'tong tien',
      'tổng cộng',
      'tong cong',
      'thành tiền',
      'thanh tien',
      'bằng số',
      'bang so',
      'khách phải trả',
      'total amount',
      'grand total',
      'amount due',
      'net total',
      'total',
    ];

    double? bestAmount;

    // 1. Duyệt từ dưới lên để ưu tiên dòng tổng kết ở cuối hóa đơn
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].toLowerCase();

      for (final keyword in totalKeywords) {
        if (line.contains(keyword)) {
          // Tìm số trên chính dòng này
          double? amount = _extractAmountFromLine(lines[i]);

          // Nếu dòng này không có số, thử xem dòng kế tiếp ngay dưới
          if (amount == null && i + 1 < lines.length) {
            amount = _extractAmountFromLine(lines[i + 1]);
          }

          if (amount != null && amount > 0) {
            return amount;
          }
        }
      }
    }

    // 2. Heuristic phụ: Quét tất cả các số có định dạng tiền tệ và lấy số lớn nhất hợp lý
    final List<double> candidateAmounts = [];
    for (final line in lines) {
      // Bỏ qua các dòng có vẻ là ngày tháng hoặc số điện thoại
      if (line.contains('/') || line.contains('-') && line.length < 15) continue;
      if (line.toLowerCase().contains('mst') || line.toLowerCase().contains('tel')) continue;

      final amount = _extractAmountFromLine(line);
      if (amount != null && amount >= 1000 && amount <= 50000000) {
        candidateAmounts.add(amount);
      }
    }

    if (candidateAmounts.isNotEmpty) {
      candidateAmounts.sort();
      // Chọn giá trị lớn nhất trong các khoản hợp lý
      bestAmount = candidateAmounts.last;
    }

    return bestAmount;
  }

  /// Trích xuất số tiền từ một dòng văn bản
  static double? _extractAmountFromLine(String line) {
    // Xử lý trường hợp dạng "150k" hoặc "150 k"
    final kMatch = RegExp(r'(\d+)\s*[kK]\b').firstMatch(line);
    if (kMatch != null) {
      final val = double.tryParse(kMatch.group(1) ?? '');
      if (val != null) return val * 1000;
    }

    // Xử lý dạng chuẩn: 150.000 hoặc 150,000 hoặc 1,250,000 hoặc $25.50
    final moneyPattern = RegExp(
      r'(?:₫|VND|VNĐ|\$)?\s*(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{1,2})?|\d{4,9})(?:\s*(?:₫|VND|VNĐ))?',
      caseSensitive: false,
    );

    final matches = moneyPattern.allMatches(line);
    double? maxInLine;

    for (final match in matches) {
      String rawNum = match.group(1) ?? '';
      if (rawNum.isEmpty) continue;

      // Chuẩn hóa dấu phân cách
      String cleaned = rawNum.replaceAll(RegExp(r'[^\d,.]'), '');
      if (cleaned.contains('.') && cleaned.contains(',')) {
        int lastDot = cleaned.lastIndexOf('.');
        int lastComma = cleaned.lastIndexOf(',');
        if (lastDot > lastComma) {
          cleaned = cleaned.replaceAll(',', '');
        } else {
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        }
      } else if (cleaned.contains('.')) {
        List<String> parts = cleaned.split('.');
        if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
          cleaned = cleaned.replaceAll('.', '');
        }
      } else if (cleaned.contains(',')) {
        List<String> parts = cleaned.split(',');
        if (parts.length > 2 || (parts.length == 2 && parts[1].length == 3)) {
          cleaned = cleaned.replaceAll(',', '');
        } else {
          cleaned = cleaned.replaceAll(',', '.');
        }
      }

      final parsed = double.tryParse(cleaned);
      if (parsed != null && parsed > 0) {
        if (maxInLine == null || parsed > maxInLine) {
          maxInLine = parsed;
        }
      }
    }

    return maxInLine;
  }

  /// Gợi ý danh mục chi tiêu dựa trên tên cửa hàng và nội dung hóa đơn
  static CategoryItem _suggestCategory(String? merchant, List<String> lines) {
    final fullText = '${merchant ?? ''} ${lines.join(' ')}'.toLowerCase();

    // 1. Cafe & Đồ uống
    if (_containsAny(fullText, [
      'cafe',
      'cà phê',
      'trà sữa',
      'highland',
      'phúc long',
      'katinat',
      'the coffee house',
      'starbucks',
      'đá xay',
      'matcha',
      'trà sen',
      'freeze',
    ])) {
      return CategoryItem.findById('cafe');
    }

    // 2. Mua sắm & Siêu thị
    if (_containsAny(fullText, [
      'winmart',
      'circle k',
      'siêu thị',
      'bách hóa',
      'co.op',
      'lotte mart',
      'ministop',
      'gs25',
      'chợ',
      'tạp hóa',
      'tiện lợi',
      'dầu ăn',
      'nước mắm',
      'xà phòng',
      'dầu gội',
    ])) {
      return CategoryItem.findById('shopping');
    }

    // 3. Ăn uống nhà hàng
    if (_containsAny(fullText, [
      'nhà hàng',
      'quán ăn',
      'cơm niêu',
      'cơm tấm',
      'phở',
      'bún bò',
      'bbq',
      'lẩu',
      'buffet',
      'kfc',
      'lotteria',
      'jollibee',
      'pizza',
      'gà rán',
      'nướng',
      'món việt',
    ])) {
      return CategoryItem.findById('food');
    }

    // 4. Di chuyển
    if (_containsAny(fullText, [
      'grab',
      'be',
      'taxi',
      'xăng',
      'dầu',
      'petrolimex',
      'vé xe',
      'gửi xe',
      'bãi đỗ',
      'mai linh',
      'vận tải',
    ])) {
      return CategoryItem.findById('transport');
    }

    // 5. Sức khỏe
    if (_containsAny(fullText, [
      'pharmacity',
      'long châu',
      'an khang',
      'thuốc',
      'nhà thuốc',
      'y tế',
      'khám',
      'bệnh viện',
      'vitamin',
    ])) {
      return CategoryItem.findById('health');
    }

    // 6. Giải trí
    if (_containsAny(fullText, [
      'cgv',
      'lotte cinema',
      'rạp chiếu phim',
      'vé xem phim',
      'bida',
      'bowling',
      'karaoke',
      'game',
    ])) {
      return CategoryItem.findById('entertainment');
    }

    // 7. Hóa đơn điện nước
    if (_containsAny(fullText, [
      'điện lực',
      'tiền điện',
      'tiền nước',
      'cấp nước',
      'internet',
      'viettel',
      'vnpt',
      'fpt telecom',
      'hóa đơn vat',
    ])) {
      return CategoryItem.findById('bills');
    }

    return CategoryItem.findById('food'); // Mặc định là ăn uống
  }

  static bool _containsAny(String source, List<String> keywords) {
    for (final kw in keywords) {
      if (source.contains(kw)) return true;
    }
    return false;
  }
}
