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

        final isLockedArrivedAtPatient =
            timeMetricsModel?.lockTimeArrivedAtPatient ?? false;
        final isLockedFirstEkg = timeMetricsModel?.lockTimeOfEkgs ?? false;
        final isLockedStemiActivation =
            timeMetricsModel?.lockTimeOfStemiActivation ?? false;
        final isLockedUnitLeftScene =
            timeMetricsModel?.lockTimeUnitLeftScene ?? false;
        final isLockedPatientArrivedAtDestination =
            timeMetricsModel?.lockTimePatientArrivedAtDestination ?? false;

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
                    isLocked: isLockedArrivedAtPatient,
                    onToggleLocked: () => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .toggleTimeArrivedAtPatientLock(),
                  ),
                  TimeMetric(
                    label: 'First EKG',
                    timeOccurred: timeOfFirstEkg,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeOfFirstEkg(newTime),
                    isLocked: isLockedFirstEkg,
                    onToggleLocked: () => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .toggleTimeOfFirstEkgLock(),
                  ),
                  TimeMetric(
                    label: 'STEMI Activation',
                    timeOccurred: timeOfStemiActivation,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeOfStemiActivation(newTime),
                    isLocked: isLockedStemiActivation,
                    onToggleLocked: () => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .toggleTimeOfStemiActivationLock(),
                  ),
                  TimeMetric(
                    label: 'Unit Left Scene',
                    timeOccurred: timeUnitLeftScene,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimeUnitLeftScene(newTime),
                    isLocked: isLockedUnitLeftScene,
                    onToggleLocked: () => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .toggleTimeUnitLeftSceneLock(),
                  ),
                  TimeMetric(
                    label: 'Patient at Destination',
                    timeOccurred: timePatientArrivedAtDestination,
                    onNewTimeSaved: (newTime) => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .setTimePatientArrivedAtDestination(newTime),
                    isLocked: isLockedPatientArrivedAtDestination,
                    onToggleLocked: () => ref
                        .read(timeMetricsControllerProvider.notifier)
                        .toggleTimePatientArrivedAtDestinationLock(),
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
    required this.isLocked,
    required this.onToggleLocked,
    super.key,
  });

  final String label;
  final DateTime? timeOccurred;
  final void Function(DateTime?) onNewTimeSaved;
  final bool isLocked;
  final VoidCallback onToggleLocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    void clearDateTime() => onNewTimeSaved(null);

    Future<void> selectDateTime() async {
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
      // widget.onNewTimeSaved(null);
      return;
    }

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: timeOccurred == null
              ? [
                  FilledButton(
                    onPressed: () => onNewTimeSaved(DateTime.now()),
                    child: const Text('Now'),
                  ),
                  IconButton(
                    onPressed: isLocked ? null : selectDateTime,
                    icon: const Icon(Icons.edit_calendar_outlined),
                  ),
                ]
              : [
                  IconButton(
                    onPressed: onToggleLocked,
                    icon: isLocked
                        ? const Icon(Icons.lock)
                        : const Icon(Icons.lock_open),
                  ),
                  TimeMetricsMenu(
                    onSelectDateTime: selectDateTime,
                    onClearDateTime: clearDateTime,
                    isLocked: isLocked,
                  ),
                ],
        ),
      ),
    );
  }
}

/// spec: https://api.flutter.dev/flutter/material/MenuAnchor-class.html
class TimeMetricsMenu extends StatefulWidget {
  const TimeMetricsMenu({
    required this.onSelectDateTime,
    required this.onClearDateTime,
    required this.isLocked,
    super.key,
  });

  final VoidCallback onSelectDateTime;
  final VoidCallback onClearDateTime;
  final bool isLocked;

  @override
  State<TimeMetricsMenu> createState() => _TimeMetricsMenuState();
}

class _TimeMetricsMenuState extends State<TimeMetricsMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Time Metrics Menu');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: <Widget>[
        MenuItemButton(
          onPressed: widget.onSelectDateTime,
          child: const Text('Change Time'),
        ),
        MenuItemButton(
          onPressed: () async {
            final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Clear Time'),
                      content: const Text(
                        'Are you sure you want to clear the time?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('CLEAR TIME'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;

            if (shouldClear && context.mounted) {
              widget.onClearDateTime();
            }
          },
          child: const Text('Clear Time'),
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          focusNode: _buttonFocusNode,
          onPressed: widget.isLocked
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          icon: const Icon(Icons.more_vert),
        );
      },
    );
  }
}
