import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

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

    if (state is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: nearbyEds.items.length,
      itemBuilder: (context, index) {
        final edOption = nearbyEds.items.values.toList()[index];
        return _PlaceholderButton(
          edOption: edOption,
          nearbyEds: nearbyEds,
        );
      },
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
        title: Text(edOption.edInfo.shortName),
        leading: Column(
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
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('r: ${edOption.routeDistance}')),
            Expanded(
              child: Text('dist: ${edOption.distanceBetween.truncate()}'),
            ),
          ],
        ),
        trailing: Text(
          RouteDurationToSecondsDto()
              .routeDurationToFormattedString(edOption.routeDuration),
        ),
      ),
    );
  }
}
