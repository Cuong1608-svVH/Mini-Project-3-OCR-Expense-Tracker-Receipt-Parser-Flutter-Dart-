import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/parsed_receipt.dart';
import 'heuristic_parser_service.dart';
import 'sample_receipts_data.dart';
import 'web_ocr_helper.dart';

class OcrService {
  TextRecognizer? _recognizer;

  TextRecognizer _getRecognizer() {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  /// Xử lý ảnh hóa đơn từ đường dẫn file hoặc mảng bytes (cho Web)
  Future<ParsedReceipt> processImageFile(
    String imagePath, {
    Uint8List? imageBytes,
  }) async {
    // 1. Nếu chạy trên nền tảng di động (Android / iOS) -> Dùng Google ML Kit Offline Native
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final recognizedText = await _getRecognizer().processImage(inputImage);
        final rawText = recognizedText.text;

        if (rawText.trim().isNotEmpty) {
          return HeuristicParserService.parse(rawText);
        }
      } catch (e) {
        debugPrint('ML Kit recognition error on device: $e');
      }
    }

    // 2. Nếu chạy trên Trình duyệt Web (Chrome) -> Dùng Web OCR (Tesseract.js in-browser)
    if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
      try {
        final base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
        final webOcrText = await runWebOcr(base64Image);

        if (webOcrText.trim().isNotEmpty) {
          return HeuristicParserService.parse(webOcrText);
        }
      } catch (e) {
        debugPrint('Web OCR error: $e');
      }
    }

    // 3. Fallback khi không nhận diện được chữ (hoặc do chạy trên môi trường không hỗ trợ ML Kit)
    return const ParsedReceipt(
      merchant: 'Hóa đơn chưa nhận diện',
      date: null,
      totalAmount: 0.0,
      rawLines: [],
      rawText: 'Không tìm thấy chữ trên ảnh hoặc OCR chưa hỗ trợ đầy đủ trên nền tảng này.\n\nMẹo: Bạn có thể nhập nhanh số tiền hoặc chọn mẫu hóa đơn WinMart có sẵn để kiểm thử parser!',
      confidenceScore: 0.1,
    );
  }

  /// Xử lý một hóa đơn mẫu tích hợp sẵn để kiểm thử parser ngay lập tức
  ParsedReceipt processSample(SampleReceiptItem sample) {
    return HeuristicParserService.parse(sample.ocrText);
  }

  void dispose() {
    _recognizer?.close();
  }
}
