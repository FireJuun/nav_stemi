import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ScanQrWidget extends ConsumerWidget {
  const ScanQrWidget({required this.onItemDetected, super.key});

  final void Function(BarcodeCapture) onItemDetected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(mobileScannerControllerProvider);

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
            onDetect: onItemDetected,
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

final mobileScannerControllerProvider =
    ChangeNotifierProvider.autoDispose<MobileScannerController>((ref) {
  return MobileScannerController(
    torchEnabled: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
});
