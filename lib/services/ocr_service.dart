import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService {
  static final textRecognizer = TextRecognizer();

  static Future<String?> processImage(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // First try to find *104*<digits># pattern
      final voucherPattern = RegExp(r'\*104\*\d{12,16}\#');
      final match = voucherPattern.firstMatch(recognizedText.text);
      if (match != null) return match.group(0);
      
      // If not found, look for standalone 12-16 digit numbers
      final digitPattern = RegExp(r'\b\d{12,16}\b');
      final digitMatch = digitPattern.firstMatch(recognizedText.text);
      return digitMatch?.group(0);
    } catch (e) {
      throw Exception('OCR processing error: $e');
    }
  }
}