import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/services/heuristic_parser_service.dart';
import 'package:ocr_expense_tracker/services/sample_receipts_data.dart';

void main() {
  group('HeuristicParserService Tests', () {
    test('Correctly parses User WinMart Photo 1 (Cam & Meat Deli - 68,097d)', () {
      final sample = SampleReceiptsData.samples.firstWhere((s) => s.id == 'winmart_real_1');
      final result = HeuristicParserService.parse(sample.ocrText);

      expect(result.merchant, equals('WinMart'));
      expect(result.totalAmount, equals(68097.0));
      expect(result.date?.day, equals(6));
      expect(result.date?.month, equals(3));
      expect(result.date?.year, equals(2026));
      expect(result.suggestedCategoryId, equals('shopping'));
    });

    test('Correctly parses User WinMart Photo 2 (WinMart+ Xot me rang & Tao - 237,576d)', () {
      final sample = SampleReceiptsData.samples.firstWhere((s) => s.id == 'winmart_real_2');
      final result = HeuristicParserService.parse(sample.ocrText);

      expect(result.merchant, equals('WinMart+'));
      expect(result.totalAmount, equals(237576.0));
      expect(result.date?.day, equals(25));
      expect(result.date?.month, equals(4));
      expect(result.date?.year, equals(2026));
      expect(result.suggestedCategoryId, equals('shopping'));
    });

    test('Correctly parses Highlands Coffee receipt', () {
      final sample = SampleReceiptsData.samples.firstWhere((s) => s.id == 'highlands');
      final result = HeuristicParserService.parse(sample.ocrText);

      expect(result.merchant, contains('Highlands'));
      expect(result.totalAmount, equals(129000.0));
      expect(result.date?.day, equals(12));
      expect(result.date?.month, equals(10));
      expect(result.date?.year, equals(2026));
      expect(result.suggestedCategoryId, equals('cafe'));
      expect(result.confidenceScore, greaterThan(0.7));
    });

    test('Correctly parses Restaurant receipt', () {
      final sample = SampleReceiptsData.samples.firstWhere((s) => s.id == 'restaurant');
      final result = HeuristicParserService.parse(sample.ocrText);

      expect(result.merchant?.toUpperCase(), contains('NHÀ HÀNG CƠM NIÊU'));
      expect(result.totalAmount, equals(580000.0));
      expect(result.suggestedCategoryId, equals('food'));
    });

    test('Correctly parses GrabCar receipt', () {
      final sample = SampleReceiptsData.samples.firstWhere((s) => s.id == 'grab');
      final result = HeuristicParserService.parse(sample.ocrText);

      expect(result.merchant, contains('Grab'));
      expect(result.totalAmount, equals(85000.0));
      expect(result.suggestedCategoryId, equals('transport'));
    });
  });
}
