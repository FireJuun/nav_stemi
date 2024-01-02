import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class GoToDialog extends StatelessWidget {
  const GoToDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      child: Center(
        child: Column(
          children: [
            ResponsiveDialogHeader(label: 'Go'.hardcoded),
            Expanded(child: Text('text'.hardcoded)),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}
