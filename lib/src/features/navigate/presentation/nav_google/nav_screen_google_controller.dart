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
  ActiveDestinationRepository get _activeDestinationRepository =>
      ref.read(activeDestinationRepositoryProvider);
  GoogleNavigationService get _googleNavigationService =>
      ref.read(googleNavigationServiceProvider);

  @override
  FutureOr<void> build() async {
    await _googleNavigationService.initialize();

    ref.onDispose(() {
      _googleNavigationService.cleanup();
    });
  }

  /// These methods are called from the UI
  /// They are not reliant on any state, so they can be called directly
  Future<void> onViewCreated(GoogleNavigationViewController controller) async {
    _controller.complete(controller);
    await controller.setMyLocationEnabled(true);
    final isLocationEnabled = await controller.isMyLocationEnabled();
    final destination =
        _activeDestinationRepository.activeDestination?.destination;

    if (isLocationEnabled && destination != null) {
      await _googleNavigationService.calculateDestinationRoutes();
    }
  }

  Future<LatLng?> userLocation() =>
      _controller.future.then((controller) async => controller.getMyLocation());

  void linkEdInfoToDestination(EdInfo edInfo) =>
      _googleNavigationService.linkEdInfoToDestination(edInfo);

  void setAudioGuidanceType(NavigationAudioGuidanceType guidanceType) =>
      unawaited(_googleNavigationService.setAudioGuidanceType(guidanceType));

  void startDrivingDirections() =>
      unawaited(_googleNavigationService.startDrivingDirections());

  void stopDrivingDirections() =>
      unawaited(_googleNavigationService.stopDrivingDirections());

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
        _controller.future
            .then((controller) async => controller.showRouteOverview()),
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

  /// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation.dart
  /// Functions below handled here
}
