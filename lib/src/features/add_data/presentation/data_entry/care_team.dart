import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class CareTeam extends StatelessWidget {
  const CareTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        DataEntryHeader('Care Team'.hardcoded),
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
