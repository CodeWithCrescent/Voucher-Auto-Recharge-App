import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tz_voucher_recharge/services/ocr_service.dart';
import 'package:tz_voucher_recharge/services/ussd_service.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voucherController = useTextEditingController();
    final selectedNetwork = useState<String?>(null);
    final isLoading = useState(false);
    final showCamera = useState(false);
    final cameraController = useState<CameraController?>(null);
    final scannedText = useState<String?>(null);

    final networks = [
      'Vodacom',
      'Tigo',
      'Airtel',
      'Halotel',
      'TTCL',
      'Zantel',
    ];

    Future<void> initCamera() async {
      final cameras = await availableCameras();
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      await controller.initialize();
      cameraController.value = controller;
    }

    Future<void> scanVoucher() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        isLoading.value = true;
        await initCamera();
        showCamera.value = true;
      } catch (e) {
        isLoading.value = false;
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }

    Future<void> processImage(XFile image) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final text = await OcrService.processImage(image);
        if (text != null) {
          // Extract voucher number (12-16 digits)
          final regex = RegExp(r'\b\d{12,16}\b');
          final match = regex.firstMatch(text);

          if (match != null) {
            voucherController.text = match.group(0)!;
            scannedText.value = match.group(0);
            showCamera.value = false;
            cameraController.value?.dispose();
            cameraController.value = null;
          } else {
            messenger.showSnackBar(
              const SnackBar(
                  content: Text(
                      'No valid voucher number found. Please try again or enter manually.')),
            );
          }
        }
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('OCR processing failed: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> recharge() async {
      final messenger = ScaffoldMessenger.of(context);
      if (voucherController.text.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
              content: Text('Please enter or scan a voucher number')),
        );
        return;
      }

      if (voucherController.text.length < 12 ||
          voucherController.text.length > 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher number must be 12-16 digits')),
        );
        return;
      }

      try {
        isLoading.value = true;
        await UssdService.rechargeVoucher(voucherController.text);
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to initiate recharge: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TZ Voucher Recharge'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: voucherController,
                  decoration: const InputDecoration(
                    labelText: 'Voucher Number',
                    border: OutlineInputBorder(),
                    hintText: 'Enter 12-16 digit voucher number',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Scan Voucher'),
                        onPressed: isLoading.value ? null : scanVoucher,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () => voucherController.clear(),
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedNetwork.value,
                  decoration: const InputDecoration(
                    labelText: 'Select Network (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: networks.map((network) {
                    return DropdownMenuItem(
                      value: network,
                      child: Text(network),
                    );
                  }).toList(),
                  onChanged: (value) => selectedNetwork.value = value,
                  hint: const Text('Select your network'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading.value ? null : recharge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Recharge', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
          if (showCamera.value && cameraController.value != null)
            _CameraOverlay(
              controller: cameraController.value!,
              onImageCaptured: processImage,
              onClose: () {
                showCamera.value = false;
                cameraController.value?.dispose();
                cameraController.value = null;
              },
            ),
        ],
      ),
    );
  }
}

class _CameraOverlay extends StatelessWidget {
  final CameraController controller;
  final Function(XFile) onImageCaptured;
  final VoidCallback onClose;

  const _CameraOverlay({
    required this.controller,
    required this.onImageCaptured,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(controller),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: onClose,
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final image = await controller.takePicture();
                  await onImageCaptured(image);
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to capture image: $e')),
                  );
                }
              },
              child: const Icon(Icons.camera, size: 30),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Position the voucher number in the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
