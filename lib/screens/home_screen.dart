import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        errorMessage.value = null;
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [LanguageToggle()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C3E50).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.quickRecharge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.scanOrEnter,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Voucher Input Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: Color(0xFF3498DB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.voucherDetails,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: voucherController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.enterVoucher,
                      hintText: l10n.voucherHint,
                      prefixIcon: const Icon(
                        Icons.confirmation_number,
                        color: Color(0xFF3498DB),
                      ),
                      labelStyle: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
                    ),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner, size: 22),
                      label: Text(
                        l10n.scan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        backgroundColor: Colors.transparent,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading.value ? null : startScanning,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.flash_on, size: 22),
                      label: Text(
                        l10n.rechargeNow,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading.value ? null : recharge,
                    ),
                  ),
                ),
              ],
            ),

            // Error Message
            if (errorMessage.value != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage.value!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Scanner Preview
            if (showScanner.value && cameraController.value != null)
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: ScannerPreview(
                  controller: cameraController.value!,
                  onTextDetected: processScannedText,
                  onClose: () {
                    showScanner.value = false;
                    cameraController.value?.dispose();
                    cameraController.value = null;
                  },
                ),
              ),

            // Footer with developer info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Developed by Crescent Sambila',
                    style: TextStyle(
                      color: const Color(0xFF2C3E50).withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.5',
                    style: TextStyle(
                      color: const Color(0xFF2C3E50).withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}