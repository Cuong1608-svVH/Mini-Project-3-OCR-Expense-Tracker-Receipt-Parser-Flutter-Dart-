import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/models/transaction_item.dart';
import 'package:ocr_expense_tracker/services/csv_export_service.dart';

void main() {
  test('Exports transactions to CSV with UTF-8 BOM', () async {
    final tempDir = await Directory.systemTemp.createTemp('csv_test_');

    final transactions = [
      TransactionItem(
        id: 1,
        title: 'Cà phê sáng Highlands',
        amount: 35000,
        isExpense: true,
        categoryId: 'cafe',
        categoryName: 'Cafe & Trà sữa',
        dateTime: DateTime(2026, 10, 12, 8, 30),
        merchant: 'Highlands Coffee',
        note: 'Hóa đơn quét OCR',
        rawOcrText: 'HIGHLANDS COFFEE...',
      ),
      TransactionItem(
        id: 2,
        title: 'Tiền thưởng dự án',
        amount: 5000000,
        isExpense: false,
        categoryId: 'bonus',
        categoryName: 'Thưởng',
        dateTime: DateTime(2026, 10, 10, 14, 0),
        note: 'Dự án hoàn thành',
      ),
    ];

    final result = await CsvExportService.exportTransactionsToCsv(
      transactions,
      customFileName: 'test_export.csv',
      customDirectoryPath: tempDir.path,
    );

    // Kiểm tra kết quả
    expect(result.isSuccess, isTrue);
    expect(result.recordCount, equals(2));
    expect(result.filePath, contains('test_export.csv'));

    // Kiểm tra nội dung file
    final file = File(result.filePath);
    expect(await file.exists(), isTrue);
    final content = await file.readAsString();

    // Phải có BOM \uFEFF ở đầu file
    expect(content.startsWith('\uFEFF'), isTrue);
    expect(content, contains('Mã giao dịch'));
    expect(content, contains('Cà phê sáng Highlands'));
    expect(content, contains('35000'));
    expect(content, contains('5000000'));

    // Dọn dẹp temp
    await tempDir.delete(recursive: true);
  });
}
