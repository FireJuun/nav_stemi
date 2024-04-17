import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ScanQrLicenseDialog extends StatefulWidget {
  const ScanQrLicenseDialog({super.key});

  @override
  State<ScanQrLicenseDialog> createState() => _ScanQrLicenseDialogState();
}

class _ScanQrLicenseDialogState extends State<ScanQrLicenseDialog> {
  final cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.pdf417],
  );

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      denseHeight: true,
      child: Column(
        children: [
          ResponsiveDialogHeader(label: "Scan Driver's License".hardcoded),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    final disabledColor = Theme.of(context).disabledColor;
                    final enabledColor = Theme.of(context).colorScheme.primary;
                    switch (state) {
                      case TorchState.off:
                        return Icon(Icons.flash_off, color: disabledColor);
                      case TorchState.on:
                        return Icon(Icons.flash_on, color: enabledColor);
                    }
                  },
                ),
                onPressed: cameraController.toggleTorch,
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                onPressed: cameraController.switchCamera,
              ),
            ],
          ),
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.driverLicense != null) {
                    debugPrint(
                      'Driver License found! ${barcode.driverLicense}',
                    );
                  }
                  debugPrint('Barcode found! ${barcode.rawValue}');
                }
              },
            ),
          ),
          // TODO(FireJuun): add remove
          ResponsiveDialogFooter(label: 'Close'.hardcoded),
        ],
      ),
    );
  }
}
