import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class DataEntryTabs extends StatelessWidget {
  const DataEntryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Divider(color: colorScheme.primary),
          TabBar(
            tabs: [
              Text(
                'Time Metrics'.hardcoded,
                textAlign: TextAlign.center,
              ),
              Text(
                'Patient Info'.hardcoded,
                textAlign: TextAlign.center,
              ),
              Text(
                'Care Team'.hardcoded,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Divider(color: colorScheme.primary),
          const Expanded(
            child: TabBarView(
              children: [
                DataEntryView(child: TimeMetrics()),
                DataEntryView(child: PatientInfo()),
                DataEntryView(child: CareTeam()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataEntryView extends StatelessWidget {
  const DataEntryView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [child],
    );
  }
}
