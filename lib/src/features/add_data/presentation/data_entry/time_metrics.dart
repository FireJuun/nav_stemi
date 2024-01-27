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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.list(
            children: const [
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
              Text('text'),
            ],
          ),
        ),
      ],
    );
  }
}
