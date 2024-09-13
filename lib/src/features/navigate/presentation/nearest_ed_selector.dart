import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _routeDurationDto = RouteDurationDto();

class NearestEdSelector extends ConsumerWidget {
  const NearestEdSelector({
    required this.availableRoutes,
    required this.activeRoute,
    super.key,
  });

  final AvailableRoutes availableRoutes;
  final ActiveRoute activeRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const DestinationInfo(),
        const EtaWidget(),
        gapH4,
        NearestEdButtons(
          availableRoutes: availableRoutes,
          activeRoute: activeRoute,
        ),
      ],
    );
  }
}

class NearestEdButtons extends ConsumerWidget {
  const NearestEdButtons({
    required this.availableRoutes,
    required this.activeRoute,
    super.key,
  });

  final AvailableRoutes availableRoutes;
  final ActiveRoute activeRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyEdsValue = ref.watch(nearbyEdsProvider);

    return AsyncValueWidget<NearbyEds>(
      value: nearbyEdsValue,
      data: (nearbyEds) {
        final isCurrentRoutePCI = availableRoutes.destinationInfo.isPCI;
        final nextClosestRoute = nearbyEds.items.values
            .firstWhereOrNull((ed) => ed.edInfo.isPCI != isCurrentRoutePCI);

        if (nextClosestRoute == null) {
          throw NextClosestRouteNotAvailableException();
        }

        final durationMin = _routeDurationDto
            .routeDurationToMinsString(nextClosestRoute.routeDuration);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// PCI route
            if (isCurrentRoutePCI) ...[
              FilledButton(
                onPressed: () {},
                child: const Text('PCI (active)'),
              ),
              OutlinedButton(
                onPressed: () => ref
                    .read(goToDialogControllerProvider.notifier)
                    .goToEd(activeEd: nextClosestRoute, nearbyEds: nearbyEds),
                child: Text('ED $durationMin'),
              ),
            ]

            /// Non-PCI route
            else ...[
              OutlinedButton(
                onPressed: () => ref
                    .read(goToDialogControllerProvider.notifier)
                    .goToEd(activeEd: nextClosestRoute, nearbyEds: nearbyEds),
                child: Text('PCI $durationMin'),
              ),
              FilledButton(
                onPressed: () {},
                child: const Text('ED (active)'),
              ),
            ],

            IconButton(
              onPressed: () {
                /// refresh current location and list of nearby EDs
                ref
                  ..invalidate(nearbyEdsProvider)
                  ..invalidate(getCurrentPositionProvider);
                context.goNamed(AppRoute.navGoTo.name);
              },
              icon: const Icon(Icons.more_horiz),
            ),
          ],
        );
      },
    );
  }
}
