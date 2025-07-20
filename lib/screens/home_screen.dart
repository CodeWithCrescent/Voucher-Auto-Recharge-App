import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tz_voucher_recharge/services/ussd_service.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voucherController = useTextEditingController();
    final isLoading = useState(false);
    final showScanner = useState(false);
    final cameraController = useState<CameraController?>(null);
    final errorMessage = useState<String?>(null);

    Future<void> initCamera() async {
      final cameras = await availableCameras();
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      cameraController.value = controller;
    }

    Future<void> startScanning() async {
      try {
        isLoading.value = true;
        errorMessage.value = null;
        await initCamera();
        showScanner.value = true;
      } catch (e) {
        isLoading.value = false;
        errorMessage.value = 'Failed to initialize camera: $e';
      }
    }

    Future<void> processScannedText(String text) async {
      // Improved pattern matching for Tanzanian vouchers
      final patterns = [
        // Matches *104*<digits># pattern
        RegExp(r'\*104\*(\d{12,16})\#'),
        // Matches groups of 4-5 digits separated by spaces
        RegExp(r'(\d{4}\s\d{4}\s\d{4}\s?\d{0,4})'), // Yas, Vodacom
        RegExp(r'(\d{5}\s\d{5}\s\d{4})'), // Airtel
        RegExp(r'(\d{4}\s\d{5}\s\d{4})'), // Halotel
        // RegExp(r'(\d{12,16})'),
      ];

      String? extractedVoucher;
      
      for (final pattern in patterns) {
        final match = pattern.firstMatch(text.replaceAll(RegExp(r'\s+'), ''));
        if (match != null) {
          extractedVoucher = match.group(1)?.replaceAll(RegExp(r'\s+'), '');
          if (extractedVoucher != null && 
              extractedVoucher.length >= 12 && 
              extractedVoucher.length <= 16) {
            break;
          }
        }
      }

      if (extractedVoucher != null) {
        voucherController.text = extractedVoucher;
        showScanner.value = false;
        cameraController.value?.dispose();
        cameraController.value = null;
      } else {
        errorMessage.value = 'No valid voucher found. Please try again.';
      }
    }

    Future<void> recharge() async {
      if (voucherController.text.isEmpty) {
        errorMessage.value = 'Please enter or scan a voucher number';
        return;
      }

      if (voucherController.text.length < 12 ||
          voucherController.text.length > 16) {
        errorMessage.value = 'Voucher must be 12-16 digits';
        return;
      }

      try {
        isLoading.value = true;
        await UssdService.rechargeVoucher(voucherController.text);
        errorMessage.value = null;
      } catch (e) {
        errorMessage.value = 'Recharge failed: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Recharge'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voucher Input Field
            TextField(
              controller: voucherController,
              decoration: InputDecoration(
                labelText: 'Voucher Number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.confirmation_number),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => voucherController.clear(),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16,
            ),
            const SizedBox(height: 20),

            // Scan Button
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Voucher'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: isLoading.value ? null : startScanning,
            ),
            const SizedBox(height: 20),

            // Recharge Button
            ElevatedButton(
              onPressed: isLoading.value ? null : recharge,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Recharge Now', style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )),
            ),
            const SizedBox(height: 20),

            // Error Message
            if (errorMessage.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage.value!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Scanner Preview (not full screen)
            if (showScanner.value && cameraController.value != null)
              _ScannerPreview(
                controller: cameraController.value!,
                onTextDetected: processScannedText,
                onClose: () {
                  showScanner.value = false;
                  cameraController.value?.dispose();
                  cameraController.value = null;
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPreview extends StatefulWidget {
  final CameraController controller;
  final Function(String) onTextDetected;
  final VoidCallback onClose;

  const _ScannerPreview({
    required this.controller,
    required this.onTextDetected,
    required this.onClose,
  });

  @override
  State<_ScannerPreview> createState() => _ScannerPreviewState();
}

class _ScannerPreviewState extends State<_ScannerPreview> {
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

      // Improved text processing with multiple patterns
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
    final cameraAspectRatio = widget.controller.value.aspectRatio;

    return Column(
      children: [
        const Text(
          'Align voucher number within frame',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 75,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: 100 * cameraAspectRatio, // maintain aspect
                height: 100 * cameraAspectRatio,
                child: CameraPreview(widget.controller),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 30),
              onPressed: widget.onClose,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.camera_alt, size: 30),
              onPressed: _processCameraImage,
            ),
          ],
        ),
      ],
    );
  }
}
