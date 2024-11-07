import 'dart:async';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_screen_google_controller.g.dart';

@riverpod
class NavScreenGoogleController extends _$NavScreenGoogleController {
  final Completer<GoogleNavigationViewController> _controller =
      Completer<GoogleNavigationViewController>();

  final _latLngBounds = LatLngBoundsDTO();

  @override
  FutureOr<void> build() {
    // nothing to do
  }

  /// These methods are called from the UI
  /// They are not reliant on any state, so they can be called directly
  void onViewCreated(GoogleNavigationViewController controller) {
    _controller.complete(controller);
    controller.setMyLocationEnabled(true);
  }

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

  void zoomToActiveRoute() => unawaited(
        _controller.future.then((controller) async {
          final currentLocation =
              await ref.read(getLastKnownOrCurrentPositionProvider.future);

          final destination = ref.read(destinationProvider);

          if (destination != null) {
            await controller.animateCamera(
              CameraUpdate.newLatLngBounds(
                _latLngBounds.listToBounds([
                  currentLocation.toLatLng(),
                  destination,
                ]),
                padding: 72,
              ),
            );
          }
        }),
      );

  void zoomToSelectedNavigationStep(List<LatLng> stepLocations) => unawaited(
        _controller.future.then((controller) async {
          await controller.animateCamera(
            CameraUpdate.newLatLngBounds(
              _latLngBounds.listToBounds(stepLocations),
              padding: 72,
            ),
          );
        }),
      );

  void showCurrentLocation() => unawaited(
        _controller.future.then((controller) async {
          final currentLocation =
              await ref.read(getLastKnownOrCurrentPositionProvider.future);

          await controller.animateCamera(
            // CameraUpdate.newLatLng(currentLocation.toLatLng()),
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation.toLatLng(),
                zoom: 14,
              ),
            ),
          );
        }),
      );

  /// These methods are called from the UI
  /// They are reliant on state, so they are called via ref
  /// If any errors occur, they are caught, logged, and displayed to the user
  // TODO(FireJuun): run guarded, navigation route calls
}
