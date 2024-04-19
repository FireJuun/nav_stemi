import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

enum ScanQrSubRoute { scan, confirm }

class ScanQrLicenseDialog extends StatefulWidget {
  const ScanQrLicenseDialog({super.key});

  @override
  State<ScanQrLicenseDialog> createState() => _ScanQrLicenseDialogState();
}

class _ScanQrLicenseDialogState extends State<ScanQrLicenseDialog> {
  final pageController = PageController(initialPage: ScanQrSubRoute.scan.index);

  DriverLicense? scannedLicense;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      denseHeight: true,
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ScanQrWidget(
            onItemDetected: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.driverLicense != null) {
                  debugPrint(
                    'Driver License found! ${barcode.driverLicense}',
                  );

                  setState(() {
                    scannedLicense = barcode.driverLicense;
                  });
                  pageController.animateToPage(
                    ScanQrSubRoute.confirm.index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
                debugPrint('Barcode found! ${barcode.rawValue}');
              }
            },
          ),
          ScanQrAcceptData(
            scannedLicense: scannedLicense,
            onRescanLicense: () {
              pageController.animateToPage(
                ScanQrSubRoute.scan.index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}
