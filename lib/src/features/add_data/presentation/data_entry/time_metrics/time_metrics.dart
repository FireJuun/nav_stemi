import 'package:flutter/material.dart';

class TimeMetrics extends StatelessWidget {
  const TimeMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          sliver: SliverList.list(
            children: const [
              TimeMetric(
                label: 'Patient Contact',
                timeOccurred: null,
                // timeAgoInMins: '20 min ago',
              ),
              TimeMetric(
                label: 'First ECG',
                timeOccurred: null,
                // timeOccurred: '3:15 pm',
                // timeAgoInMins: '12 min ago',
              ),
              // TODO(FireJuun): should this be ED notification?
              TimeMetric(
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.schedule)),
          ],
        ),
        subtitle: Padding(
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
        trailing: FilledButton(onPressed: () {}, child: const Text('Set')),
      ),
    );
  }
}
