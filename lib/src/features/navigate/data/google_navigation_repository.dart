import 'dart:async';

import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation_without_map.dart

part 'google_navigation_repository.g.dart';

typedef TermsAccepted = bool;
typedef SessionInitialized = bool;
typedef RouteCalculated = bool;
typedef GuidanceRunning = bool;

class GoogleNavigationRepository {
  /// Various listeners, used to update the UI with the latest information.
  /// Each listener uses an InMemoryStore, so that the latest value can be
  /// broadcasted to the UI when a widget is rebuilt.
  ///
  /// We are also using a StreamSubscription to listen to the events from the
  /// Google Maps Navigator SDK.
  final _navInfoStore = InMemoryStore<NavInfo?>(null);
  NavInfo? get navInfo => _navInfoStore.value;
  set navInfo(NavInfo? value) => _navInfoStore.value = value;

  Stream<NavInfo?> watchNavInfo() => _navInfoStore.stream;
  StreamSubscription<NavInfoEvent>? _navInfoEventSubscription;

  Future<void> _setupListeners() async {
    /// Subscribe to each event only once.
    _clearListeners();

    // Turn-by-turn nav info listener with up to 30 steps ahead.
    _navInfoEventSubscription = GoogleMapsNavigator.setNavInfoListener(
      _onNavInfoEvent,
      numNextStepsToPreview: 30,
    );
  }

  void _clearListeners() {
    _navInfoEventSubscription?.cancel();
    _navInfoEventSubscription = null;
  }

  void _onNavInfoEvent(NavInfoEvent event) => navInfo = event.navInfo;

  Future<TermsAccepted> areTermsAccepted() async =>
      GoogleMapsNavigator.areTermsAccepted();

  Future<void> resetTermsAccepted() async =>
      GoogleMapsNavigator.resetTermsAccepted();

  Future<TermsAccepted> showTermsAndConditionsDialog({
    required String title,
    required String companyName,
    bool shouldOnlyShowDriverAwarenessDisclaimer = false,
  }) async {
    return GoogleMapsNavigator.showTermsAndConditionsDialog(
      title,
      companyName,
      shouldOnlyShowDriverAwarenessDisclaimer:
          shouldOnlyShowDriverAwarenessDisclaimer,
    );
  }

  Future<SessionInitialized> isInitialized() =>
      GoogleMapsNavigator.isInitialized();

  Future<void> initializeNavigationSession() async {
    await _setupListeners();
    return GoogleMapsNavigator.initializeNavigationSession();
  }

  Future<void> cleanupNavigationSession() async {
    _clearListeners();
    await GoogleMapsNavigator.cleanup();
  }

  Future<NavigationRouteStatus> setDestinations(
    Destinations destinations,
  ) async =>
      GoogleMapsNavigator.setDestinations(destinations);

  Future<void> clearDestinations() async =>
      GoogleMapsNavigator.clearDestinations();

  Future<GuidanceRunning> isGuidanceRunning() async =>
      GoogleMapsNavigator.isGuidanceRunning();

  Future<void> startGuidance() async => GoogleMapsNavigator.startGuidance();

  Future<void> stopGuidance() async => GoogleMapsNavigator.stopGuidance();

  Future<void> simulateUserLocation(LatLng location) async =>
      GoogleMapsNavigator.simulator.setUserLocation(location);

  Future<void> simulateLocationsAlongExistingRoute() async =>
      GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  ) async =>
      GoogleMapsNavigator.simulator
          .simulateLocationsAlongExistingRouteWithOptions(options);

  Future<void> pauseSimulation() async =>
      GoogleMapsNavigator.simulator.pauseSimulation();

  Future<void> resumeSimulation() async =>
      GoogleMapsNavigator.simulator.resumeSimulation();

  Future<void> stopSimulation() async =>
      GoogleMapsNavigator.simulator.removeUserLocation();
}

@riverpod
GoogleNavigationRepository googleNavigationRepository(
  GoogleNavigationRepositoryRef ref,
) {
  return GoogleNavigationRepository();
}
