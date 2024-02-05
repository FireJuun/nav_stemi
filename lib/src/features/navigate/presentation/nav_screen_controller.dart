import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_screen_controller.g.dart';

@riverpod
class NavScreenController extends _$NavScreenController {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  FutureOr<void> build() {
    // nothing to do
  }

  void onMapCreated(GoogleMapController controller) =>
      _controller.complete(controller);

  void zoomIn() => unawaited(
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.zoomIn());
        }),
      );

  void zoomOut() => unawaited(
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.zoomOut());
        }),
      );

  void showCurrentLocation() => unawaited(
        _controller.future.then((controller) async {
          final currentLocation =
              await ref.read(mapsServiceProvider).currentLocation();
          await controller
              .animateCamera(CameraUpdate.newLatLng(currentLocation));
        }),
      );
}
