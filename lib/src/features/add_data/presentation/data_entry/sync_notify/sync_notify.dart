import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncNotify extends ConsumerWidget {
  const SyncNotify({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: const [
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
