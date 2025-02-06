import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

// TODO(FireJuun): should these be modifiable via settings?
const _countUpTimeWarningThreshold = Duration(minutes: 45);
const _countUpTimeErrorThreshold = Duration(minutes: 60);

class CountUpTimerView extends ConsumerWidget {
  const CountUpTimerView({this.height = 60, super.key});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final timer = ref.watch(countUpTimerProvider);
    final timerDuration = timerIntAsDuration(timer.value);

    final containerColor = switch (timerDuration) {
      < Duration.zero => colorScheme.error,
      >= Duration.zero && < _countUpTimeWarningThreshold =>
        colorScheme.tertiary.lighten().withAlpha(110),
      >= _countUpTimeWarningThreshold && < _countUpTimeErrorThreshold =>
        // ignore: avoid_redundant_argument_values
        Colors.yellow[700],
      >= _countUpTimeErrorThreshold => colorScheme.error,
      _ => colorScheme.error,
    };
    final foregroundColor = containerColor == colorScheme.error
        ? colorScheme.onError
        : colorScheme.onTertiaryContainer;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        // TODO(FireJuun): setup test for color logic
        color: containerColor,
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
              color: foregroundColor,
              heightDelta: -.33,
            ),
          ),
          Text(
            timerIntToString(timer.value),
            textAlign: TextAlign.end,
            style: textTheme.headlineMedium?.apply(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
