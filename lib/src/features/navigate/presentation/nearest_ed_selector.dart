import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NearestEdSelector extends StatelessWidget {
  const NearestEdSelector({
    super.key,
    this.onTapNearestPciCenter,
    this.onTapNearestEd,
  });

  final VoidCallback? onTapNearestPciCenter;
  final VoidCallback? onTapNearestEd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        gapH8,
        const Text('Time to closest'),
        gapH12,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilledButton(
              onPressed: onTapNearestPciCenter,
              child: const Text('PCI Center\n24 min'),
            ),
            OutlinedButton(
              onPressed: onTapNearestEd,
              child: const Text('ED\n17 min'),
            ),
          ],
        ),
      ],
    );
  }
}
