import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class TimeMetrics extends StatelessWidget {
  const TimeMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        DataEntryHeader('Time Metrics'.hardcoded),
        SliverPadding(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          sliver: SliverList.list(
            children: const [
              TimeMetric(
                label: 'Arrival on Scene',
                timeOccurred: '3:04 pm',
                timeAgoInMins: '32 min ago',
              ),
              TimeMetric(
                label: 'Patient Contact',
                timeOccurred: '3:07 pm',
                timeAgoInMins: '20 min ago',
              ),
              TimeMetric(
                label: 'First ECG',
                timeOccurred: '3:15 pm',
                timeAgoInMins: '12 min ago',
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
    required this.timeAgoInMins,
    super.key,
  });

  final String label;
  final String timeOccurred;
  final String timeAgoInMins;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: ListTile(
        title: Text(label),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeAgoInMins),
              Text(
                timeOccurred,
                style: Theme.of(context).textTheme.bodyMedium?.apply(
                      fontStyle: FontStyle.italic,
                      fontWeightDelta: -1,
                    ),
              ),
            ],
          ),
        ),
        trailing: FilledButton(onPressed: () {}, child: const Text('Set')),
      ),
    );
  }
}
