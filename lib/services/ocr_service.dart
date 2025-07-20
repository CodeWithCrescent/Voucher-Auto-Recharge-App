import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService {
  static Future<String?> processImage(XFile imageFile) async {
    try {
      final textRecognizer = TextRecognizer();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR processing error: $e');
    }
  }
}