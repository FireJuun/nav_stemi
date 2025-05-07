import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

// TODO(FireJuun): should these be modifiable via settings?
const _countUpTimeWarningThreshold = Duration(minutes: 45);
const _countUpTimeErrorThreshold = Duration(minutes: 60);
const _countUpTimePastErrorThreshold = Duration(minutes: 90);

enum TimerDurationState {
  running,
  warning,
  error,
  pastError,
  unknown,
}

class CountUpTimerView extends ConsumerWidget {
  const CountUpTimerView({this.height = 60, super.key});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final timer = ref.watch(countUpTimerProvider);
    final timerDuration = timerIntAsDuration(timer.value);

    // TODO(FireJuun): setup tests for color logic
    final timerDurationState = switch (timerDuration) {
      <= Duration.zero => TimerDurationState.unknown,
      > Duration.zero && < _countUpTimeWarningThreshold =>
        TimerDurationState.running,
      >= _countUpTimeWarningThreshold && < _countUpTimeErrorThreshold =>
        TimerDurationState.warning,
      >= _countUpTimeErrorThreshold && < _countUpTimePastErrorThreshold =>
        TimerDurationState.error,
      >= _countUpTimePastErrorThreshold => TimerDurationState.pastError,
      _ => TimerDurationState.unknown,
    };

    final containerColor = switch (timerDurationState) {
      TimerDurationState.unknown => Colors.transparent,
      TimerDurationState.running => colorScheme.tertiary.lighten(20),
      TimerDurationState.warning => Colors.yellow[700],
      TimerDurationState.error => colorScheme.error,
      TimerDurationState.pastError => Colors.black,
    };

    final foregroundColor = switch (timerDurationState) {
      TimerDurationState.unknown => Colors.transparent,
      TimerDurationState.running => colorScheme.onTertiaryContainer,
      TimerDurationState.warning => colorScheme.onTertiaryContainer,
      TimerDurationState.error => colorScheme.onError,
      TimerDurationState.pastError => colorScheme.onError,
    };

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: containerColor,
        border: timerDurationState == TimerDurationState.running ||
                timerDurationState == TimerDurationState.warning
            ? Border.all(
                color: colorScheme.onTertiaryContainer,
                width: 4,
              )
            : null,
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
