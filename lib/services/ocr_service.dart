import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService {
  static final textRecognizer = TextRecognizer();

  static Future<String?> processImage(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      
      // Clean the text by removing non-digit characters (except * and #)
      final cleanText = recognizedText.text.replaceAll(RegExp(r'[^0-9\s\*#]'), '');
      
      // Check for *104* pattern first
      final ussdPattern = RegExp(r'\*104\*(\d{12,16})\#');
      final ussdMatch = ussdPattern.firstMatch(cleanText);
      if (ussdMatch != null) return ussdMatch.group(1);
      
      // Check for Tanzanian voucher patterns
      final voucherPatterns = [
        RegExp(r'\*104\*(\d+)\#'), // Direct USSD code with digits
        RegExp(r'(\d{4}\s\d{4}\s\d{4}\s?\d{0,4})'), // Yas, Vodacom
        RegExp(r'(\d{5}\s\d{5}\s\d{4})'), // Airtel
        RegExp(r'(\d{4}\s\d{5}\s\d{4})'), // Halotel
      ];
      
      for (final pattern in voucherPatterns) {
        final match = pattern.firstMatch(cleanText);
        if (match != null) {
          final digits = match.group(1)?.replaceAll(RegExp(r'\s+'), '');
          if (digits != null && digits.length >= 12 && digits.length <= 16) {
            return digits;
          }
        }
      }
      
      return null;
    } catch (e) {
      throw Exception('OCR processing error: $e');
    }
  }
}