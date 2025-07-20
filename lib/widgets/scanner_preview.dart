import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tz_voucher_recharge/localizations/app_localizations.dart';

class ScannerPreview extends StatefulWidget {
  final CameraController controller;
  final Function(String) onTextDetected;
  final VoidCallback onClose;

  const ScannerPreview({
    super.key,
    required this.controller,
    required this.onTextDetected,
    required this.onClose,
  });

  @override
  State<ScannerPreview> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<ScannerPreview> {
  final textRecognizer = TextRecognizer();
  bool isProcessing = false;

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _processCameraImage() async {
    if (isProcessing) return;
    isProcessing = true;
    try {
      final image = await widget.controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text.replaceAll(RegExp(r'[^0-9\s\*#]'), '');
      widget.onTextDetected(text);
    } catch (e) {
      widget.onClose();
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              l10n.alignVoucher,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3498DB), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: CameraPreview(widget.controller),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(color: Color(0xFFE74C3C)),
                  ),
                  child: const Icon(Icons.close, color: Color(0xFFE74C3C)),
                ),
                ElevatedButton(
                  onPressed: _processCameraImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}