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
            const Expanded(child: _PlaceholderData()),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderData extends StatelessWidget {
  const _PlaceholderData();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PlaceholderButton('Watauga Medical Center\n148 min'),
        _PlaceholderButton('Ashe Memorial Hospital\n120 min'),
        _PlaceholderButton('Wake Forest Baptist (PCI)\n48 min'),
        _PlaceholderButton('Iredell Memorial (PCI)\n32 min'),
        _PlaceholderButton('Frye Regional Med Center\n24 min'),
        _PlaceholderButton('Blue Ridge Valdese\n17 min'),
      ],
    );
  }
}

class _PlaceholderButton extends StatelessWidget {
  const _PlaceholderButton(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OutlinedButton(
        onPressed: () {},
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
