import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ScanQrAcceptData extends StatelessWidget {
  const ScanQrAcceptData({
    required this.onAccept,
    required this.onRescanLicense,
    super.key,
  });

  final VoidCallback onAccept;
  final VoidCallback onRescanLicense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveDialogHeader(label: 'Import Patient Info?'.hardcoded),
        Expanded(
          child: Column(
            children: [
              FilledButton(
                onPressed: onRescanLicense,
                child: Text('Rescan License'.hardcoded),
              ),
              gapH8,
              const Divider(thickness: 4),
              gapH16,
              const Text('Pt info goes here'),
            ],
          ),
        ),
        ResponsiveDialogFooter(
          includeAccept: true,
          onAccept: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
