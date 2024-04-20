import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

// TODO(FireJuun): deprecate this widget
class CareTeamHeader extends StatelessWidget {
  const CareTeamHeader(this.label, {this.trailing, super.key});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverPinnedHeader(
      child: ColoredBox(
        color: colorScheme.secondaryContainer,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style:
                      textTheme.titleMedium?.apply(color: colorScheme.primary),
                ),
                trailing ?? const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
