import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

enum ScanQrSubRoute { scan, confirm }

class ScanQrLicenseDialog extends StatefulWidget {
  const ScanQrLicenseDialog({super.key});

  @override
  State<ScanQrLicenseDialog> createState() => _ScanQrLicenseDialogState();
}

class _ScanQrLicenseDialogState extends State<ScanQrLicenseDialog> {
  final pageController = PageController(initialPage: ScanQrSubRoute.scan.index);

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
            onItemScanned: () {
              pageController.animateToPage(
                ScanQrSubRoute.confirm.index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          ScanQrAcceptData(
            onAccept: () {},
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
