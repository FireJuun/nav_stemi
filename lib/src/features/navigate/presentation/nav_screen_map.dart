import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreenMap extends ConsumerWidget {
  const NavScreenMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      initialLocationProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final initialLocationValue = ref.watch(initialLocationProvider);

    return AsyncValueWidget<LatLng>(
      value: initialLocationValue,
      data: (initialLocation) => Consumer(
        builder: (context, ref, child) {
          /// currently following the location of the user
          /// should this be implemented?
          /// will it redraw the map everytime the user moves?
          ref.watch(currentLocationProvider);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 14,
            ),
            trafficEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) => ref
                .read(navScreenControllerProvider.notifier)
                .onMapCreated(controller),
            markers: ref.watch(markersProvider),
            polylines: ref.watch(polylinesProvider),
          );
        },
      ),
    );
  }
}
