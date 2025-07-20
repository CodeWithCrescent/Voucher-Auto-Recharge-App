import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tz_voucher_recharge/localizations/app_localizations.dart';
import 'package:tz_voucher_recharge/services/ussd_service.dart';
import 'package:tz_voucher_recharge/widgets/language_toggle.dart';
import 'package:tz_voucher_recharge/widgets/scanner_preview.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
        await UssdService.rechargeVoucher(voucherController.text);
        errorMessage.value = null;
      } catch (e) {
        errorMessage.value = '${l10n.rechargeFailed}: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.appTitle, style: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        )),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        actions: const [LanguageToggle()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.quickRecharge, style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 8),
                  Text(l10n.scanOrEnter, style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Voucher Input Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.voucherDetails, style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    )),
                    const SizedBox(height: 16),
                    TextField(
                      controller: voucherController,
                      decoration: InputDecoration(
                        labelText: l10n.enterVoucher,
                        labelStyle: const TextStyle(color: Color(0xFF7F8C8D)),
                        hintText: l10n.voucherHint,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3498DB)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: Text(l10n.scan),
                    onPressed: isLoading.value ? null : startScanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.flash_on, size: 20),
                    label: Text(l10n.rechargeNow),
                    onPressed: isLoading.value ? null : recharge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            
            // Error Message
            if (errorMessage.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEDED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage.value!,
                          style: const TextStyle(color: Color(0xFFE74C3C)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Scanner Preview
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
            
            // Footer
            const SizedBox(height: 24),
            const Text(
              'Version 1.0.5 • Developed by Crescent Sambila',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}