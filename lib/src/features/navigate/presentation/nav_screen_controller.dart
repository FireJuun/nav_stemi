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

  void showCurrentLocation() => unawaited(
        _controller.future.then((controller) async {
          final currentLocation = ref.read(currentLocationProvider).value;

          if (currentLocation != null) {
            await controller
                .animateCamera(CameraUpdate.newLatLng(currentLocation));
          }
        }),
      );

  /// These methods are called from the UI
  /// They are reliant on state, so they are called via ref
  /// If any errors occur, they are caught, logged, and displayed to the user
  // TODO(FireJuun): run guarded, navigation route calls
}
