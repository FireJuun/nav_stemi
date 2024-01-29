import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class DataEntryHeader extends StatelessWidget {
  const DataEntryHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPinnedHeader(
      child: ColoredBox(
        color: colorScheme.secondaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.apply(color: colorScheme.primary),
            ),
            Divider(
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
