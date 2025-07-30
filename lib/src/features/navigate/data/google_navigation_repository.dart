import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation_without_map.dart

part 'google_navigation_repository.g.dart';

typedef TermsAccepted = bool;
typedef SessionInitialized = bool;
typedef RouteCalculated = bool;
typedef GuidanceRunning = bool;

/// QUESTION: should this use GoogleNavigationService instead
/// of the google_navigation_flutter dependency directly?
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

  StreamSubscription<void>? _onRouteChangedSubscription;

  Future<void> _setupListeners() async {
    /// Subscribe to each event only once.
    _clearListeners();
    debugPrint('Setting up listeners');

    // Turn-by-turn nav info listener with up to 30 steps ahead.
    _navInfoEventSubscription = GoogleMapsNavigator.setNavInfoListener(
      _onNavInfoEvent,
      numNextStepsToPreview: 30,
    );

    // Rerouting event listener.
    _onRouteChangedSubscription =
        GoogleMapsNavigator.setOnRouteChangedListener(_onRouteChangedEvent);
  }

  void _clearListeners() {
    debugPrint('Clearing listeners');
    _navInfoEventSubscription?.cancel();
    _navInfoEventSubscription = null;

    _onRouteChangedSubscription?.cancel();
    _onRouteChangedSubscription = null;
  }

  void _onNavInfoEvent(NavInfoEvent event) => navInfo = event.navInfo;

  void _onRouteChangedEvent() {
    debugPrint('Route Changed');
  }

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

  Future<SessionInitialized> isInitialized() async {
    final isInitialized = await GoogleMapsNavigator.isInitialized();
    debugPrint('isInitialized: $isInitialized');
    return isInitialized;
  }

  Future<void> initializeNavigationSession() async {
    debugPrint('Initializing navigation session');
    await GoogleMapsNavigator.initializeNavigationSession();
    await _setupListeners();
  }

  Future<void> cleanupNavigationSession() async {
    debugPrint('Cleaning up navigation session');
    _clearListeners();
    await GoogleMapsNavigator.cleanup();
  }

  Future<List<RouteSegment>> getRouteSegments() async {
    debugPrint('Calculating route segments');
    return GoogleMapsNavigator.getRouteSegments();
  }

  Future<void> setAudioGuidance(NavigationAudioGuidanceSettings settings) {
    debugPrint('Setting audio guidance');
    return GoogleMapsNavigator.setAudioGuidance(settings);
  }

  Future<NavigationRouteStatus> setDestinations(
    Destinations destinations,
  ) async =>
      GoogleMapsNavigator.setDestinations(destinations);

  Future<void> clearDestinations() async =>
      GoogleMapsNavigator.clearDestinations();

  Future<GuidanceRunning> isGuidanceRunning() async =>
      GoogleMapsNavigator.isGuidanceRunning();

  Future<void> startGuidance() async {
    debugPrint('Starting guidance');
    await GoogleMapsNavigator.startGuidance();
  }

  Future<void> stopGuidance() async {
    debugPrint('Stopping guidance');
    await GoogleMapsNavigator.stopGuidance();
  }

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
GoogleNavigationRepository googleNavigationRepository(Ref ref) {
  return GoogleNavigationRepository();
}

@riverpod
Stream<NavInfo?> navInfo(Ref ref) {
  return ref.watch(googleNavigationRepositoryProvider).watchNavInfo();
}
