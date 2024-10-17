import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/features/add_data/presentation/data_entry/sync_notify/sync_notify.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GoToDialog extends StatelessWidget {
  const GoToDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      child: Center(
        child: Column(
          children: [
            ResponsiveDialogHeader(label: 'Go'.hardcoded),
            const Expanded(child: ListEDOptions()),
            const ResponsiveDialogFooter(),
          ],
        ),
      ),
    );
  }
}

class ListEDOptions extends ConsumerWidget {
  const ListEDOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listen(
        nearbyEdsProvider,
        (_, state) => state.showAlertDialogOnError(context),
      )
      ..listen(
        goToDialogControllerProvider,
        (_, state) => state.showAlertDialogOnError(context),
      );

    final nearbyEdsValue = ref.watch(nearbyEdsProvider);

    return AsyncValueWidget<NearbyEds>(
      value: nearbyEdsValue,
      data: _DialogOption.new,
    );
  }
}

class _DialogOption extends ConsumerWidget {
  const _DialogOption(this.nearbyEds, {super.key});

  final NearbyEds nearbyEds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goToDialogControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
          itemCount: nearbyEds.items.length,
          itemBuilder: (context, index) {
            final edOption = nearbyEds.items.values.toList()[index];
            return _PlaceholderButton(
              edOption: edOption,
              nearbyEds: nearbyEds,
            );
          },
        ),
      ],
    );
  }
}

class _PlaceholderButton extends ConsumerWidget {
  const _PlaceholderButton({required this.edOption, required this.nearbyEds});

  final NearbyEd edOption;
  final NearbyEds nearbyEds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        edOption.edInfo.isPCI ? colorScheme.onPrimary : colorScheme.onSecondary;
    final backgroundColor =
        edOption.edInfo.isPCI ? colorScheme.primary : colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListTile(
        tileColor: backgroundColor,
        textColor: foregroundColor,
        onTap: () => ref
            .read(goToDialogControllerProvider.notifier)
            .goToEd(activeEd: edOption, nearbyEds: nearbyEds),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              edOption.edInfo.isPCI
                  ? Icons.monitor_heart_outlined
                  : Icons.local_hospital,
              color: foregroundColor,
            ),
            Text(edOption.edInfo.isPCI ? 'PCI'.hardcoded : 'ED'.hardcoded),
          ],
        ),
        title: Text(edOption.edInfo.shortName),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              const RouteDurationDto()
                  .routeDurationToFormattedString(edOption.routeDuration),
            ),
            Text(
              '${edOption.distanceBetweenInMiles.toStringAsFixed(1)} mi',
              textAlign: TextAlign.end,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
