import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavSteps extends ConsumerWidget {
  const NavSteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navInfoValue = ref.watch(navInfoProvider);

    return AsyncValueWidget<NavInfo?>(
      value: navInfoValue,
      data: (navInfo) {
        final currentStep = navInfo?.currentStep;

        if (navInfo == null || currentStep == null) {
          return const Center(child: Text('--'));
        }

        final routeSteps = [
          currentStep,
          ...navInfo.remainingSteps,
        ];

        return ListView.builder(
          itemCount: routeSteps.length,
          itemBuilder: (context, index) => NavStep(
            routeLegStep: routeSteps[index],
            onTap: null,
            // TODO(FireJuun): Google Navigation Flutter doesn't have a way to zoom to a specific step
            /// This can be achieved by reimplementing Google routes API,
            /// but as is, we cannot confirm that both routes link to
            /// the same location without adding additional checks.
            /// Probably not worth the effort for 2x API calls.
            ///

            // onTap: () {
            // final routeLegStep = routeSteps[index];
            // final startLocation = routeLegStep.startLocation?.latLng;
            // final endLocation = routeLegStep.endLocation?.latLng;

            // if (startLocation != null && endLocation != null) {
            //   final startLocationAsGoogleMap =
            //       AppWaypoint.fromGoogleRoutes(startLocation).toGoogleMaps();
            //   final endLocationAsGoogleMap =
            //       AppWaypoint.fromGoogleRoutes(endLocation).toGoogleMaps();

            //   ref
            //       .read(navScreenGoogleControllerProvider.notifier)
            //       .zoomToSelectedNavigationStep([
            //     startLocationAsGoogleMap,
            //     endLocationAsGoogleMap,
            //   ]);
            // }
            // },
          ),
        );
      },
    );
  }
}
