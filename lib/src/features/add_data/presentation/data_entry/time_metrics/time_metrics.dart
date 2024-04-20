import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The amount of days to add/subtract from the current date
/// to set the minimum and maximum date for the date picker.
final _durationBufferAgo = 5.days;
final _durationBufferFuture = 1.days;

class TimeMetrics extends StatelessWidget {
  const TimeMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          sliver: SliverList.list(
            children: [
              TimeMetric(
                label: 'Patient Contact',
                timeOccurred: DateTime.now(),
                // timeAgoInMins: '20 min ago',
              ),
              const TimeMetric(
                label: 'First ECG',
                timeOccurred: null,
                // timeOccurred: '3:15 pm',
                // timeAgoInMins: '12 min ago',
              ),
              // TODO(FireJuun): should this be ED notification?
              const TimeMetric(
                label: 'STEMI Activation',
                timeOccurred: null,
                // timeOccurred: '3:17 pm',
                // timeAgoInMins: '10 min ago',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TimeMetric extends StatelessWidget {
  const TimeMetric({
    required this.label,
    required this.timeOccurred,
    super.key,
  });

  final String label;
  final DateTime? timeOccurred;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.apply(fontWeightDelta: 1),
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

                    // TODO(FireJuun): update timeOccurred to this new time
                    debugPrint('New time: $newTime');
                  }
                }
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
                    const Text('20 m ago'),
                    Text(
                      '4:15 pm',
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                            fontStyle: FontStyle.italic,
                            fontWeightDelta: -1,
                          ),
                    ),
                  ],
                ),
              ),
        trailing: (timeOccurred == null)
            ? FilledButton(onPressed: () {}, child: const Text('Now'))
            : IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit),
              ),
      ),
    );
  }
}
