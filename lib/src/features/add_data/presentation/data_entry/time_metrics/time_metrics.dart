import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

/// The amount of days to add/subtract from the current date
/// to set the minimum and maximum date for the date picker.
final _durationBufferAgo = 5.days;
final _durationBufferFuture = 1.days;

class TimeMetrics extends ConsumerWidget {
  const TimeMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeMetricsModelValue = ref.watch(timeMetricsModelProvider);

    return AsyncValueSliverWidget<TimeMetricsModel?>(
      value: timeMetricsModelValue,
      data: (timeMetricsModel) {
        final timeArrivedAtPatient = timeMetricsModel?.timeArrivedAtPatient;
        final timeOfFirstEkg = timeMetricsModel?.timeOfEkgs.firstOrNull;
        final timeOfStemiActivation = timeMetricsModel?.timeOfStemiActivation;
        final timeUnitLeftScene = timeMetricsModel?.timeUnitLeftScene;
        final timePatientArrivedAtDestination =
            timeMetricsModel?.timePatientArrivedAtDestination;

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsetsDirectional.only(bottom: 24),
              sliver: SliverList.list(
                children: [
                  TimeMetric(
                    label: 'Arrived at Patient',
                    timeOccurred: timeArrivedAtPatient,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeArrivedAtPatient(newTime),
                  ),
                  TimeMetric(
                    label: 'First EKG',
                    timeOccurred: timeOfFirstEkg,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeOfFirstEkg(newTime),
                  ),
                  TimeMetric(
                    label: 'STEMI Activation',
                    timeOccurred: timeOfStemiActivation,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeOfStemiActivation(newTime),
                  ),
                  TimeMetric(
                    label: 'Unit Left Scene',
                    timeOccurred: timeUnitLeftScene,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeUnitLeftScene(newTime),
                  ),
                  TimeMetric(
                    label: 'Patient at Destination',
                    timeOccurred: timePatientArrivedAtDestination,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimePatientArrivedAtDestination(newTime),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TimeMetric extends StatelessWidget {
  const TimeMetric({
    required this.label,
    required this.timeOccurred,
    required this.onNewTimeSaved,
    super.key,
  });

  final String label;
  final DateTime? timeOccurred;
  final void Function(DateTime?) onNewTimeSaved;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textTheme.bodyLarge?.apply(fontWeightDelta: 1),
            ),
            IconButton(
              onPressed: () async {
                final now = DateTime.now();
                final initialTime = TimeOfDay.fromDateTime(timeOccurred ?? now);
                final minDate = now.subtract(_durationBufferAgo);
                final maxDate = now.add(_durationBufferFuture);

                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );
                if (selectedTime != null && context.mounted) {
                  final selectedDate = await showDatePicker(
                    context: context,
                    firstDate: minDate,
                    lastDate: maxDate,
                    initialDate: timeOccurred ?? now,
                  );

                  if (selectedDate != null) {
                    final newTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    onNewTimeSaved(newTime);
                    return;
                  }
                }

                /// If the user cancels the time picker or the date picker
                /// set the DateTime to null.
                onNewTimeSaved(null);
                return;
              },
              icon: const Icon(Icons.schedule),
            ),
          ],
        ),
        subtitle: (timeOccurred == null)
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Timeago(
                        date: timeOccurred!,
                        allowFromNow: true,
                        // locale: 'en_short',
                        refreshRate: 15.seconds,
                        builder: (context, formatted) {
                          final errorColor = colorScheme.error;
                          final isInTheFuture =
                              formatted.toLowerCase().contains('from now');

                          return Text(
                            formatted,
                            maxLines: 2,
                            style: textTheme.bodySmall?.apply(
                              fontStyle: FontStyle.italic,
                              color: isInTheFuture ? errorColor : null,
                              fontWeightDelta: isInTheFuture ? 0 : -1,
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      TimeOfDay.fromDateTime(timeOccurred!).format(context),
                      style: textTheme.bodyMedium?.apply(
                        fontStyle: FontStyle.italic,
                        fontWeightDelta: -1,
                      ),
                    ),
                  ],
                ),
              ),
        trailing: (timeOccurred == null)
            ? FilledButton(
                onPressed: () => onNewTimeSaved(DateTime.now()),
                child: const Text('Now'),
              )
            : IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
      ),
    );
  }
}
