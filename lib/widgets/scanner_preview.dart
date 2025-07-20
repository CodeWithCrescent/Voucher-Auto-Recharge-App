import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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

class _ScannerPreviewState extends State<ScannerPreview>
    with SingleTickerProviderStateMixin {
  final textRecognizer = TextRecognizer();
  bool isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _processCameraImage() async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final image = await widget.controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text.replaceAll(RegExp(r'[^0-9\s\*#]'), '');
      widget.onTextDetected(text);
    } catch (_) {
      widget.onClose();
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const scanHeight = 200.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera Preview with minimal overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: scanHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreview(widget.controller),
                      ),
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanLineAnimation.value * (scanHeight - 2),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.cyanAccent.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Minimal Button Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade500,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _processCameraImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Capture'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
