import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tz_voucher_recharge/localizations/app_localizations.dart';
import 'package:tz_voucher_recharge/widgets/language_toggle.dart';
import 'package:tz_voucher_recharge/widgets/scanner_preview.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voucherController = useTextEditingController();
    final isLoading = useState(false);
    final showScanner = useState(false);
    final cameraController = useState<CameraController?>(null);
    final errorMessage = useState<String?>(null);

    Future<void> initCamera() async {
      final cameras = await availableCameras();
      final controller = CameraController(cameras.first, ResolutionPreset.high);
      await controller.initialize();
      cameraController.value = controller;
    }

    Future<void> startScanning() async {
      try {
        errorMessage.value = null;
        await initCamera();
        showScanner.value = true;
      } catch (e) {
        errorMessage.value = l10n.cameraFailed;
      }
    }

    Future<void> processScannedText(String text) async {
      final cleanedText = text.replaceAll(RegExp(r'\s+'), ' ');
      final patterns = [
        RegExp(r'\*104\*(\d+)\#'),
        RegExp(r'(\d{4}\s\d{4}\s\d{4}\s?\d{0,4})'),
        RegExp(r'(\d{5}\s\d{5}\s\d{4})'),
        RegExp(r'(\d{4}\s\d{5}\s\d{4})'),
      ];

      String? extractedVoucher;
      for (final pattern in patterns) {
        final match = pattern.firstMatch(cleanedText);
        if (match != null) {
          extractedVoucher = match.group(1)?.replaceAll(RegExp(r'\s+'), '');
          if (extractedVoucher != null && extractedVoucher.length >= 12 && extractedVoucher.length <= 16) {
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
        errorMessage.value = l10n.noValidVoucher;
      }
    }

    Future<void> recharge() async {
      if (voucherController.text.isEmpty) {
        errorMessage.value = l10n.enterOrScan;
        return;
      }

      if (voucherController.text.length < 12 || voucherController.text.length > 16) {
        errorMessage.value = l10n.voucherLength;
        return;
      }

      try {
        isLoading.value = true;
        // await UssdService.rechargeVoucher(voucherController.text);
        errorMessage.value = null;
      } catch (e) {
        errorMessage.value = '${l10n.rechargeFailed}: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LanguageToggle()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(l10n.voucherDetails, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextField(
                      controller: voucherController,
                      decoration: InputDecoration(
                        labelText: l10n.enterVoucher,
                        hintText: l10n.voucherHint,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l10n.scan),
                    onPressed: isLoading.value ? null : startScanning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: isLoading.value 
                        ? const CircularProgressIndicator() 
                        : const Icon(Icons.flash_on),
                    label: Text(l10n.rechargeNow),
                    onPressed: isLoading.value ? null : recharge,
                  ),
                ),
              ],
            ),
            if (errorMessage.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (showScanner.value && cameraController.value != null)
              ScannerPreview(
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