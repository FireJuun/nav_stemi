import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ScanQrWidget extends StatefulWidget {
  const ScanQrWidget({required this.onItemDetected, super.key});

  final void Function(BarcodeCapture) onItemDetected;

  @override
  State<ScanQrWidget> createState() => _ScanQrWidgetState();
}

class _ScanQrWidgetState extends State<ScanQrWidget> {
  final cameraController = MobileScannerController(
    torchEnabled: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
    // TODO(FireJuun): Compare newer barcode formats for licenses
    /// Previously, pdf417 was sufficient
    /// However, newer barcode formats seem to exist in addition to pdf417.
    /// Need to review and re-implement format restrictions.
    // formats: [BarcodeFormat.pdf417],
  );

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveDialogHeader(label: "Scan Driver's License".hardcoded),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController,
                builder: (context, state, child) {
                  final disabledColor = Theme.of(context).disabledColor;
                  final enabledColor = Theme.of(context).colorScheme.primary;
                  switch (state.torchState) {
                    case TorchState.off:
                      return Icon(Icons.flash_off, color: disabledColor);
                    case TorchState.on:
                      return Icon(Icons.flash_on, color: enabledColor);
                    case TorchState.auto:
                    case TorchState.unavailable:
                      return Icon(Icons.question_mark, color: disabledColor);
                  }
                },
              ),
              onPressed: cameraController.toggleTorch,
            ),
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController,
                builder: (context, state, child) {
                  switch (state.cameraDirection) {
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
            onDetect: widget.onItemDetected,
          ),
        ),
        // TODO(FireJuun): add remove
        ResponsiveDialogFooter(
          label: 'Cancel'.hardcoded,
          includeAccept: true,
        ),
      ],
    );
  }
}
