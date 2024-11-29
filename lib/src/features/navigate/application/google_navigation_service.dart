import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_navigation_service.g.dart';

/// Includes methods to interact with the Google Navigation SDK.
/// It is responsible for initializing the navigation session,
/// setting destinations, starting and stopping guidance, and
/// simulating user locations.
///
/// Note that certain location / notification permissions are
/// required for the Google Navigation SDK to function properly.
/// These are handled separately by the [PermissionsService].
///
class GoogleNavigationService {
  const GoogleNavigationService(this.ref);

  final Ref ref;

  // TODO(FireJuun): extract into settings
  static const _includeSimulationWithGuidanceSetting = true;
  static const _simulationSpeedMultiplier = 5.0;

  ActiveDestinationRepository get activeDestinationRepository =>
      ref.read(activeDestinationRepositoryProvider);
  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);
  GoogleNavigationRepository get googleNavigationRepository =>
      ref.read(googleNavigationRepositoryProvider);
  PermissionsService get permissionsService =>
      ref.read(permissionsServiceProvider);

  Future<void> initialize() async {
    await checkTermsAccepted();
    await permissionsService.initialize();

    await checkSessionInitialized();
  }

  Future<void> checkTermsAccepted() async {
    if (!await googleNavigationRepository.areTermsAccepted()) {
      final accepted = await showTermsAndConditionsDialog();
      if (!accepted) {
        throw GoogleNavInitializationTermsNotAcceptedException();
      }
    }
  }

  @visibleForTesting
  Future<bool> showTermsAndConditionsDialog({
    bool shouldOnlyShowDriverAwarenessDisclaimer = false,
  }) async {
    final title = 'Nav STEMI'.hardcoded;
    final companyName = 'Atrium Health'.hardcoded;

    return googleNavigationRepository.showTermsAndConditionsDialog(
      title: title,
      companyName: companyName,
      shouldOnlyShowDriverAwarenessDisclaimer:
          shouldOnlyShowDriverAwarenessDisclaimer,
    );
  }

  @visibleForTesting
  Future<void> resetTermsAccepted() async {
    try {
      await googleNavigationRepository.resetTermsAccepted();
    } on ResetTermsAndConditionsException {
      throw GoogleNavResetTermsAndConditionsException();
    }
  }

  @visibleForTesting
  Future<void> checkSessionInitialized() async {
    final isInitialized = await googleNavigationRepository.isInitialized();
    if (!isInitialized) {
      await initializeNavigationSession();
    }
  }

  @visibleForTesting
  Future<void> initializeNavigationSession() async {
    try {
      await googleNavigationRepository.initializeNavigationSession();
    } on SessionInitializationException catch (e) {
      switch (e.code) {
        case SessionInitializationError.locationPermissionMissing:
          throw LocationPermissionMissingException();
        case SessionInitializationError.termsNotAccepted:
          throw GoogleNavInitializationTermsNotAcceptedException();
        case SessionInitializationError.notAuthorized:
          throw GoogleNavInitializationNotAuthorizedException();
      }
    }
  }

  Future<void> cleanup() async {
    if (await googleNavigationRepository.isGuidanceRunning()) {
      await stopGuidance();
    }
    await googleNavigationRepository.cleanupNavigationSession();
  }

  void linkEdInfoToDestination(EdInfo edInfo) {
    final latitude = edInfo.location.latitude;
    final longitude = edInfo.location.longitude;

    final destination = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: edInfo.shortName,
          target: LatLng(latitude: latitude, longitude: longitude),
        ),
      ],
      displayOptions: NavigationDisplayOptions(
        showDestinationMarkers: true,
        showStopSigns: true,
        showTrafficLights: true,
      ),
    );

    activeDestinationRepository.activeDestination =
        ActiveDestination(destination: destination, destinationInfo: edInfo);
  }

  Future<void> setAudioGuidanceType(
    NavigationAudioGuidanceType guidanceType,
  ) async {
    final settings = NavigationAudioGuidanceSettings(
      guidanceType: guidanceType,
    );

    try {
      await googleNavigationRepository.setAudioGuidance(settings);
    } on SessionNotInitializedException {
      throw GoogleNavSetAudioGuidanceSessionNotInitializedException();
    }
  }

  Future<RouteCalculated> calculateDestinationRoutes() async {
    final destination =
        activeDestinationRepository.activeDestination?.destination;

    if (destination == null) {
      throw GoogleNavSetDestinationSessionNotInitializedException();
    }
    try {
      final navRouteStatus =
          await googleNavigationRepository.setDestinations(destination);

      switch (navRouteStatus) {
        case NavigationRouteStatus.statusOk:
          return true;
        case NavigationRouteStatus.internalError:
          throw GoogleNavInternalErrorException();
        case NavigationRouteStatus.routeNotFound:
          throw GoogleNavRouteNotFoundException();
        case NavigationRouteStatus.networkError:
          throw GoogleNavNetworkErrorException();
        case NavigationRouteStatus.quotaExceeded:
          throw GoogleNavQuotaExceededException();
        case NavigationRouteStatus.quotaCheckFailed:
          throw GoogleNavQuotaCheckFailedException();

        case NavigationRouteStatus.apiKeyNotAuthorized:
          throw GoogleNavApiKeyNotAuthorizedException();
        case NavigationRouteStatus.statusCanceled:
          throw GoogleNavStatusCanceledException();

        case NavigationRouteStatus.duplicateWaypointsError:
          throw GoogleNavDuplicateWaypointsErrorException();
        case NavigationRouteStatus.noWaypointsError:
          throw GoogleNavNoWaypointsErrorException();
        case NavigationRouteStatus.locationUnavailable:
          throw GoogleNavLocationUnavailableException();
        case NavigationRouteStatus.waypointError:
          throw GoogleNavWaypointErrorException();
        case NavigationRouteStatus.travelModeUnsupported:
          throw GoogleNavTravelModeUnsupportedException();

        case NavigationRouteStatus.unknown:
          throw GoogleNavUnknownException();
        case NavigationRouteStatus.locationUnknown:
          throw GoogleNavLocationUnknownException();
      }
    } on SessionNotInitializedException {
      throw GoogleNavSetDestinationSessionNotInitializedException();
    }
  }

  Future<List<RouteSegment>> calculateRouteSegments() async {
    try {
      final routeSegments = await googleNavigationRepository.getRouteSegments();
      if (routeSegments.isNotEmpty) {
        return routeSegments;
      }
      throw GoogleNavRouteSegmentsEmptyException();
    } on SessionNotInitializedException {
      throw GoogleNavRouteSegmentsSessionNotInitializedException();
    }
  }

  Future<RouteCalculated> clearDestinations() async {
    try {
      await googleNavigationRepository.clearDestinations();
      return false;
    } on SessionNotInitializedException {
      throw GoogleNavClearDestinationSessionNotInitializedException();
    }
  }

  Future<void> startDrivingDirections({bool? includeSimulation}) async {
    await startGuidance();
    if (includeSimulation ?? _includeSimulationWithGuidanceSetting) {
      await simulateLocationsAlongExistingRouteWithOptions(
        SimulationOptions(speedMultiplier: _simulationSpeedMultiplier),
      );
    }
  }

  Future<void> stopDrivingDirections({bool? includeSimulation}) async {
    await stopGuidance();
    if (includeSimulation ?? _includeSimulationWithGuidanceSetting) {
      await stopSimulation();
    }
  }

  Future<GuidanceRunning> startGuidance() async {
    try {
      await googleNavigationRepository.startGuidance();
      if (await googleNavigationRepository.isGuidanceRunning()) {
        return true;
      }
      throw GoogleNavStartGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavStartGuidanceSessionNotInitializedException();
    }
  }

  Future<GuidanceRunning> stopGuidance() async {
    try {
      await googleNavigationRepository.stopGuidance();
      if (!await googleNavigationRepository.isGuidanceRunning()) {
        return false;
      }
      throw GoogleNavStopGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavStopGuidanceSessionNotInitializedException();
    }
  }

  // TODO(FireJuun): add ability to add different simulated locations
  Future<void> simulateUserLocation({
    AppWaypoint location = locationRandolphEms,
  }) async {
    try {
      await googleNavigationRepository.simulateUserLocation(
        location.toGoogleMaps(),
      );
    } on SessionNotInitializedException {
      throw GoogleNavSetUserLocationSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRoute() async {
    try {
      await googleNavigationRepository.simulateLocationsAlongExistingRoute();
    } on SessionNotInitializedException {
      throw GoogleNavSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  ) async {
    try {
      await googleNavigationRepository
          .simulateLocationsAlongExistingRouteWithOptions(options);
    } on SessionNotInitializedException {
      throw GoogleNavSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> pauseSimulation() async {
    try {
      await googleNavigationRepository.pauseSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavPauseSimulationSessionNotInitializedException();
    }
  }

  Future<void> resumeSimulation() async {
    try {
      await googleNavigationRepository.resumeSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavResumeSimulationSessionNotInitializedException();
    }
  }

  Future<void> stopSimulation() async {
    try {
      await googleNavigationRepository.stopSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavStopSimulationSessionNotInitializedException();
    }
  }
}

@Riverpod(keepAlive: true)
GoogleNavigationService googleNavigationService(
  GoogleNavigationServiceRef ref,
) {
  return GoogleNavigationService(ref);
}
