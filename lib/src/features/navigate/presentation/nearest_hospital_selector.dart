import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _routeDurationDto = RouteDurationDto();

class NearestHospitalSelector extends ConsumerWidget {
  const NearestHospitalSelector({
    required this.activeDestination,
    super.key,
  });

  final ActiveDestination activeDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navInfoValue = ref.watch(navInfoProvider);

    return AsyncValueWidget<NavInfo?>(
      value: navInfoValue,
      data: (navInfo) {
        if (navInfo == null) {
          return const SizedBox();
        }
        return Column(
          children: [
            const DestinationInfo(),
            const EtaWidget(),
            gapH4,
            NearestHospitalButtons(
              availableRoutes: navInfo,
              activeDestination: activeDestination,
            ),
          ],
        );
      },
    );
  }
}

class NearestHospitalButtons extends ConsumerWidget {
  const NearestHospitalButtons({
    required this.availableRoutes,
    required this.activeDestination,
    super.key,
  });

  final NavInfo availableRoutes;
  final ActiveDestination activeDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyHospitalsValue = ref.watch(nearbyHospitalsProvider);

    return AsyncValueWidget<NearbyHospitals>(
      value: nearbyHospitalsValue,
      data: (nearbyHospitals) {
        final isCurrentRoutePCI = activeDestination.destinationInfo.isPci();
        final nextClosestRoute = nearbyHospitals.items.values.firstWhereOrNull(
          (hospital) => hospital.hospitalInfo.isPci() != isCurrentRoutePCI,
        );

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
                child: Text('PCI (active)'.hardcoded),
              ),
              OutlinedButton(
                onPressed: () => ref
                    .read(goToDialogControllerProvider.notifier)
                    .goToHospital(
                      activeHospital: nextClosestRoute,
                      nearbyHospitals: nearbyHospitals,
                    ),
                child: Text('ED $durationMin'),
              ),
            ]

            /// Non-PCI route
            else ...[
              OutlinedButton(
                onPressed: () => ref
                    .read(goToDialogControllerProvider.notifier)
                    .goToHospital(
                      activeHospital: nextClosestRoute,
                      nearbyHospitals: nearbyHospitals,
                    ),
                child: Text('PCI $durationMin'.hardcoded),
              ),
              FilledButton(
                onPressed: () {},
                child: Text('ED (active)'.hardcoded),
              ),
            ],

            IconButton(
              onPressed: () {
                /// refresh current location and list of nearby EDs
                ref
                  ..invalidate(nearbyHospitalsProvider)
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
