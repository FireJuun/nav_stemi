import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class AddDataDialog extends StatelessWidget {
  const AddDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      child: Center(
        child: Column(
          children: [
            ResponsiveDialogHeader(label: 'Add Data'.hardcoded),
            Expanded(child: Text('Please login'.hardcoded)),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}
