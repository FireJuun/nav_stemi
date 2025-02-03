import 'dart:async';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nav_screen_google_controller.g.dart';

@riverpod
class NavScreenGoogleController extends _$NavScreenGoogleController
    with NotifierMounted {
  final Completer<GoogleNavigationViewController> _controller =
      Completer<GoogleNavigationViewController>();

  final _latLngBounds = LatLngBoundsDTO();
  ActiveDestinationRepository get _activeDestinationRepository =>
      ref.read(activeDestinationRepositoryProvider);
  GoogleNavigationRepository get _googleNavigationRepository =>
      ref.read(googleNavigationRepositoryProvider);
  GoogleNavigationService get _googleNavigationService =>
      ref.read(googleNavigationServiceProvider);

  @override
  FutureOr<void> build() async {
    state = const AsyncData(null);

    ref.onDispose(() {
      _googleNavigationService.cleanup();
      _activeDestinationRepository.activeDestination = null;
      ref.read(mapSessionReadyProvider.notifier).setValue(newValue: false);
      setUnmounted();
    });
  }

  /// These methods are called from the UI
  /// They are not reliant on any state, so they can be called directly
  Future<void> onViewCreated(GoogleNavigationViewController controller) async {
    _controller.complete(controller);
    await controller.setMyLocationEnabled(true);
    await _googleNavigationService.initialize();

    await _setControllerSettingsFromStoredNavigationSettings(controller);

    ref.read(mapSessionReadyProvider.notifier).setValue(newValue: true);
  }

  /// This is only called once, at time of map creation
  /// It is possible to set this to listen for changes in the future
  Future<void> _setControllerSettingsFromStoredNavigationSettings(
    GoogleNavigationViewController controller,
  ) async {
    final navSettings =
        ref.read(navigationSettingsRepositoryProvider).navigationSettings;

    /// Set the map style
    await setShowNorthUp(showNorthUp: navSettings.showNorthUp);

    /// Set the audio guidance type
    await _googleNavigationService
        .setAudioGuidanceType(navSettings.audioGuidanceType);
  }

  Future<void> setShowNorthUp({required bool showNorthUp}) async {
    /// North up or tilted
    await _controller.future.then(
      (controller) => controller.followMyLocation(
        showNorthUp
            ? CameraPerspective.topDownNorthUp
            : CameraPerspective.tilted,
      ),
    );
  }

  Future<LatLng?> userLocation() =>
      _controller.future.then((controller) async => controller.getMyLocation());

  void linkEdInfoToDestination(EdInfo edInfo) =>
      _googleNavigationService.linkEdInfoToDestination(edInfo);

  void setAudioGuidanceType(NavigationAudioGuidanceType guidanceType) =>
      unawaited(_googleNavigationService.setAudioGuidanceType(guidanceType));

  Future<bool> isGuidanceRunning() async =>
      _googleNavigationRepository.isGuidanceRunning();

  void setSimulationState(SimulationState simulationState) {
    switch (simulationState) {
      case SimulationState.running:
        unawaited(_googleNavigationService.resumeSimulation());
      case SimulationState.paused:
        unawaited(_googleNavigationService.pauseSimulation());
      case SimulationState.notRunning:
        unawaited(_googleNavigationService.stopSimulation());
    }
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

@riverpod
class MapSessionReady extends _$MapSessionReady {
  @override
  AsyncValue<bool> build() => const AsyncData(false);

  AsyncData<bool> setValue({required bool newValue}) =>
      state = AsyncData(newValue);
}
