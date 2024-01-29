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
        const DestinationInfo(),
        gapH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  'Nearest:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () {
                    // TODO(FireJuun): Dialog showing other EDs
                  },
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            FilledButton(
              onPressed: onTapNearestPciCenter,
              child: const Text(
                'PCI Center\n24 min',
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton(
              onPressed: onTapNearestEd,
              child: const Text(
                'ED\n17 min',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
