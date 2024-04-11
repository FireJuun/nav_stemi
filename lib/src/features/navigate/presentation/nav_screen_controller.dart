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

  /// These methods are called from the UI
  /// They are not reliant on any state, so they can be called directly
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

  void showRoute() => unawaited(
        _controller.future.then((controller) async {
          // TODO(FireJuun): implement upper/lower bounds
          // final route = await ref.read(getRouteProvider.future);

          // await controller.animateCamera(
          //   CameraUpdate.newLatLngBounds(
          //     route.bounds,
          //     50,
          //   ),
          // );
        }),
      );

  void showCurrentLocation() => unawaited(
        _controller.future.then((controller) async {
          final currentLocation =
              await ref.read(getLastKnownOrCurrentPositionProvider.future);

          await controller.animateCamera(
            CameraUpdate.newLatLng(currentLocation.toLatLng()),
          );
        }),
      );

  /// These methods are called from the UI
  /// They are reliant on state, so they are called via ref
  /// If any errors occur, they are caught, logged, and displayed to the user
  // TODO(FireJuun): run guarded, navigation route calls
}
