import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavSteps extends ConsumerWidget {
  const NavSteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRouteValue = ref.watch(activeRouteProvider);

    return AsyncValueWidget<ActiveRoute?>(
      value: activeRouteValue,
      data: (activeRoute) {
        if (activeRoute == null) {
          return const Center(child: Text('No Info Available'));
        }
        final routeSteps = activeRoute.route.routeSteps();
        return ListView.builder(
          itemCount: routeSteps.length,
          itemBuilder: (context, index) => NavStep(
            routeLegStep: routeSteps[index],
            onTap: () {
              const mapsToRoutesDTO = MapsToRoutesDTO();
              final routeLegStep = routeSteps[index];
              final startLocation = routeLegStep.startLocation?.latLng;
              final endLocation = routeLegStep.endLocation?.latLng;

              if (startLocation != null && endLocation != null) {
                ref
                    .read(navScreenControllerProvider.notifier)
                    .zoomToSelectedNavigationStep([
                  mapsToRoutesDTO.routesToMaps(startLocation),
                  mapsToRoutesDTO.routesToMaps(endLocation),
                ]);
              }
            },
          ),
        );
      },
    );
  }
}
