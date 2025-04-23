import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PriorEncountersDialog extends StatelessWidget {
  const PriorEncountersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      child: Center(
        child: Column(
          children: [
            ResponsiveDialogHeader(label: 'Prior Encounters'.hardcoded),
            const Expanded(child: _EncountersList()),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}

class _EncountersList extends ConsumerWidget {
  const _EncountersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // This will be expanded in future to show actual FHIR encounters
    // Currently just a placeholder UI to match GoToDialog styling
    return CustomScrollView(
      slivers: [
        SliverPinnedHeader(
          child: ColoredBox(
            color: colorScheme.primaryContainer,
            child: const SyncNotifyShareSession(usePrimaryColor: true),
          ),
        ),
        const SliverToBoxAdapter(child: gapH24),
        SliverList.builder(
          itemCount: 3, // Placeholder count
          itemBuilder: (context, index) {
            // Sample placeholder data
            final date = DateTime.now().subtract(Duration(days: index * 7));
            final formattedDate = '${date.month}/${date.day}/${date.year}';

            return _PlaceholderEncounterItem(
              date: formattedDate,
              index: index,
            );
          },
        ),
      ],
    );
  }
}

class _PlaceholderEncounterItem extends StatelessWidget {
  const _PlaceholderEncounterItem({
    required this.date,
    required this.index,
  });

  final String date;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = colorScheme.onSecondaryContainer;
    final backgroundColor = colorScheme.secondaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListTile(
        tileColor: backgroundColor,
        textColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          // Placeholder - would navigate to encounter details in the future
          Navigator.of(context).pop();
        },
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_shared,
              color: foregroundColor,
            ),
            Text(
              'EHR'.hardcoded,
            ),
          ],
        ),
        title: Text('Prior STEMI Event ${index + 1}'.hardcoded),
        subtitle: Text('ID: STEMI-${10000 + index}'.hardcoded),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date),
            Text(
              '${index + 1} week${index == 0 ? '' : 's'} ago'.hardcoded,
              textAlign: TextAlign.end,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
