import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class CountUpTimerView extends ConsumerWidget {
  const CountUpTimerView({this.height = 60, super.key});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final timer = ref.watch(countUpTimerProvider);

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        // TODO(FireJuun): Extract this custom color to an extension
        color: colorScheme.tertiary.lighten().withAlpha(110),
        border: Border.all(
          color: colorScheme.onTertiaryContainer,
          width: 4,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Total\nTime'.hardcoded,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.apply(
              color: colorScheme.onTertiaryContainer,
              heightDelta: -.33,
            ),
          ),
          Text(
            timerIntToString(timer.value),
            textAlign: TextAlign.end,
            style: textTheme.headlineMedium
                ?.apply(color: colorScheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}
