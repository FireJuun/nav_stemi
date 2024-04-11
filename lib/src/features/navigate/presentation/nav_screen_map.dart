import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreenMap extends ConsumerWidget {
  const NavScreenMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      getLastKnownOrCurrentPositionProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final lastKnownOrCurrentPositionValue =
        ref.watch(getLastKnownOrCurrentPositionProvider);

    return AsyncValueWidget<Position>(
      value: lastKnownOrCurrentPositionValue,
      data: (initialPosition) => GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialPosition.toLatLng(),
          zoom: 14,
        ),
        trafficEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (controller) => ref
            .read(navScreenControllerProvider.notifier)
            .onMapCreated(controller),
        markers: ref.watch(markersProvider),
        polylines: ref.watch(polylinesProvider),
      ),
    );
  }
}
