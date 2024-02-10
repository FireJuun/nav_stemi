import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    ref.listen(
      nearbyEdsProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final nearbyEds = ref.watch(nearbyEdsProvider);

    return AsyncValueWidget<NearbyEds>(
      value: nearbyEds,
      data: (nearbyEds) => ListView.builder(
        itemCount: nearbyEds.items.length,
        itemBuilder: (context, index) {
          final nearbyEd = nearbyEds.items.values.toList()[index];
          return _PlaceholderButton(nearbyEd);
        },
      ),
    );
  }
}

class _PlaceholderButton extends StatelessWidget {
  const _PlaceholderButton(this.nearbyEd);

  final NearbyEd nearbyEd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        nearbyEd.edInfo.isPCI ? colorScheme.onPrimary : colorScheme.onSecondary;
    final backgroundColor =
        nearbyEd.edInfo.isPCI ? colorScheme.primary : colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListTile(
        tileColor: backgroundColor,
        textColor: foregroundColor,
        onTap: () => context.goNamed(AppRoute.nav.name),
        title: Text(nearbyEd.edInfo.shortName),
        leading: Column(
          children: [
            Icon(
              nearbyEd.edInfo.isPCI
                  ? Icons.monitor_heart_outlined
                  : Icons.local_hospital,
              color: foregroundColor,
            ),
            Text(nearbyEd.edInfo.isPCI ? 'PCI'.hardcoded : 'ED'.hardcoded),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('r: ${nearbyEd.routeDistance}')),
            Expanded(
              child: Text('dist: ${nearbyEd.distanceBetween.truncate()}'),
            ),
          ],
        ),
        trailing: Text(
          RouteDurationToSecondsDto()
              .routeDurationToFormattedString(nearbyEd.routeDuration),
        ),
      ),
    );
  }
}
