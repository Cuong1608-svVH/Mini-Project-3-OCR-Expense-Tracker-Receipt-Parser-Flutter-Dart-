import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_item.dart';

class CsvExportResult {
  final bool isSuccess;
  final String filePath;
  final int recordCount;
  final String? errorMessage;

  const CsvExportResult({
    required this.isSuccess,
    required this.filePath,
    required this.recordCount,
    this.errorMessage,
  });
}

class CsvExportService {
  /// Xuất danh sách giao dịch ra file CSV với mã hóa UTF-8 BOM chuẩn Excel
  static Future<CsvExportResult> exportTransactionsToCsv(
    List<TransactionItem> transactions, {
    String? customFileName,
    String? customDirectoryPath,
  }) async {
    try {
      final List<List<dynamic>> rows = [];

      // Dòng tiêu đề cột chuẩn tiếng Việt
      rows.add([
        'Mã giao dịch',
        'Ngày giao dịch',
        'Giờ',
        'Loại giao dịch',
        'Danh mục',
        'Số tiền (VND)',
        'Tên giao dịch / Mô tả',
        'Điểm bán / Cửa hàng',
        'Ghi chú',
        'Nguồn dữ liệu',
      ]);

      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('HH:mm');

      for (final tx in transactions) {
        rows.add([
          tx.id ?? '',
          dateFormat.format(tx.dateTime),
          timeFormat.format(tx.dateTime),
          tx.isExpense ? 'Chi tiêu' : 'Thu nhập',
          tx.categoryName,
          tx.amount,
          tx.title,
          tx.merchant ?? '',
          tx.note ?? '',
          (tx.rawOcrText != null && tx.rawOcrText!.isNotEmpty)
              ? 'Quét hóa đơn OCR'
              : 'Nhập tay',
        ]);
      }

      // Chuyển mảng thành định dạng CSV dùng thư viện csv 8.0
      final csvString = excel.encode(rows);

      // Thêm Byte Order Mark (BOM) UTF-8 để Microsoft Excel trên Windows tự nhận tiếng Việt
      final utf8BomCsv = '\uFEFF$csvString';

      // Tạo tên file theo thời gian
      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = customFileName ?? 'Bao_Cao_Thu_Chi_MISA_$timeStamp.csv';

      // Lấy thư mục và lưu file
      if (!kIsWeb) {
        final String dirPath;
        if (customDirectoryPath != null && customDirectoryPath.isNotEmpty) {
          dirPath = customDirectoryPath;
        } else {
          final Directory docDir = await getApplicationDocumentsDirectory();
          dirPath = docDir.path;
        }

        final filePath = p.join(dirPath, fileName);
        final file = File(filePath);

        await file.writeAsString(utf8BomCsv, flush: true);

        return CsvExportResult(
          isSuccess: true,
          filePath: filePath,
          recordCount: transactions.length,
        );
      } else {
        return CsvExportResult(
          isSuccess: true,
          filePath: fileName,
          recordCount: transactions.length,
        );
      }
    } catch (e) {
      return CsvExportResult(
        isSuccess: false,
        filePath: '',
        recordCount: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Chia sẻ hoặc gửi file CSV đã xuất qua các ứng dụng khác
  static Future<void> shareCsvFile(String filePath) async {
    final xFile = XFile(filePath, mimeType: 'text/csv');
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: 'Báo cáo thu chi MISA Money Keeper',
        subject: 'Báo cáo thu chi',
      ),
    );
  }
}
