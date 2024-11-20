import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation_without_map.dart

part 'google_navigation_repository.g.dart';

typedef SessionInitialized = bool;
typedef RouteCalculated = bool;
typedef GuidanceRunning = bool;

class GoogleNavigationRepository {
  Future<bool> areTermsAccepted() async =>
      GoogleMapsNavigator.areTermsAccepted();

  Future<void> resetTermsAccepted() async {
    try {
      await GoogleMapsNavigator.resetTermsAccepted();
    } on ResetTermsAndConditionsException {
      throw GoogleNavigationResetTermsAndConditionsException();
    }
  }

  Future<bool> isInitialized() => GoogleMapsNavigator.isInitialized();

  Future<void> initialize() async {
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
    } on SessionInitializationError catch (e) {
      switch (e) {
        case SessionInitializationError.locationPermissionMissing:
          throw GoogleNavigationSessionInitializationLocationPermissionMissingException();
        case SessionInitializationError.termsNotAccepted:
          throw GoogleNavigationSessionInitializationTermsNotAcceptedException();
        case SessionInitializationError.notAuthorized:
          throw GoogleNavigationSessionInitializationNotAuthorizedException();
      }
    }
  }

  Future<bool> showTermsAndConditionsDialog({
    bool shouldOnlyShowDriverAwarenessDisclaimer = false,
  }) async {
    final title = 'Nav STEMI'.hardcoded;
    final companyName = 'Atrium Health'.hardcoded;

    return GoogleMapsNavigator.showTermsAndConditionsDialog(
      title,
      companyName,
      shouldOnlyShowDriverAwarenessDisclaimer:
          shouldOnlyShowDriverAwarenessDisclaimer,
    );
  }

  Future<SessionInitialized> initializeNavigationSession() async {
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      return true;
    } on SessionInitializationException catch (e) {
      switch (e.code) {
        case SessionInitializationError.locationPermissionMissing:
          throw GoogleNavigationSessionInitializationLocationPermissionMissingException();
        case SessionInitializationError.termsNotAccepted:
          throw GoogleNavigationSessionInitializationTermsNotAcceptedException();
        case SessionInitializationError.notAuthorized:
          throw GoogleNavigationSessionInitializationNotAuthorizedException();
      }
    }
  }

  Future<void> cleanupNavigationSession() async {
    await GoogleMapsNavigator.cleanup();
  }

  Future<RouteCalculated> setDestination(EdInfo edInfo) async {
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

    try {
      final navRouteStatus =
          await GoogleMapsNavigator.setDestinations(destination);
      switch (navRouteStatus) {
        case NavigationRouteStatus.statusOk:
          return true;
        case NavigationRouteStatus.internalError:
          throw GoogleNavigationInternalErrorException();
        case NavigationRouteStatus.routeNotFound:
          throw GoogleNavigationRouteNotFoundException();
        case NavigationRouteStatus.networkError:
          throw GoogleNavigationNetworkErrorException();
        case NavigationRouteStatus.quotaExceeded:
          throw GoogleNavigationQuotaExceededException();
        case NavigationRouteStatus.quotaCheckFailed:
          throw GoogleNavigationQuotaCheckFailedException();

        case NavigationRouteStatus.apiKeyNotAuthorized:
          throw GoogleNavigationApiKeyNotAuthorizedException();
        case NavigationRouteStatus.statusCanceled:
          throw GoogleNavigationStatusCanceledException();

        case NavigationRouteStatus.duplicateWaypointsError:
          throw GoogleNavigationDuplicateWaypointsErrorException();
        case NavigationRouteStatus.noWaypointsError:
          throw GoogleNavigationNoWaypointsErrorException();
        case NavigationRouteStatus.locationUnavailable:
          throw GoogleNavigationLocationUnavailableException();
        case NavigationRouteStatus.waypointError:
          throw GoogleNavigationWaypointErrorException();
        case NavigationRouteStatus.travelModeUnsupported:
          throw GoogleNavigationTravelModeUnsupportedException();

        case NavigationRouteStatus.unknown:
          throw GoogleNavigationUnknownException();
        case NavigationRouteStatus.locationUnknown:
          throw GoogleNavigationLocationUnknownException();
      }
    } on SessionNotInitializedException {
      throw GoogleNavigationSetDestinationSessionNotInitializedException();
    }
  }

  Future<RouteCalculated> clearDestinations() async {
    try {
      await GoogleMapsNavigator.clearDestinations();
      return false;
    } on SessionNotInitializedException {
      throw GoogleNavigationClearDestinationSessionNotInitializedException();
    }
  }

  Future<GuidanceRunning> startGuidance() async {
    try {
      await GoogleMapsNavigator.startGuidance();
      if (await GoogleMapsNavigator.isGuidanceRunning()) {
        return true;
      }
      throw GoogleNavigationStartGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavigationStartGuidanceSessionNotInitializedException();
    }
  }

  Future<GuidanceRunning> stopGuidance() async {
    try {
      await GoogleMapsNavigator.stopGuidance();
      if (!await GoogleMapsNavigator.isGuidanceRunning()) {
        return false;
      }
      throw GoogleNavigationStopGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavigationStopGuidanceSessionNotInitializedException();
    }
  }

  Future<void> simulateUserLocation() async {
    try {
      await GoogleMapsNavigator.simulator.setUserLocation(
        locationRandolphEms.toGoogleMaps(),
      );
    } on SessionNotInitializedException {
      throw GoogleNavigationSetUserLocationSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRoute() async {
    try {
      await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    } on SessionNotInitializedException {
      throw GoogleNavigationSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  ) async {
    try {
      await GoogleMapsNavigator.simulator
          .simulateLocationsAlongExistingRouteWithOptions(options);
    } on SessionNotInitializedException {
      throw GoogleNavigationSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> pauseSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.pauseSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavigationPauseSimulationSessionNotInitializedException();
    }
  }

  Future<void> resumeSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.resumeSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavigationResumeSimulationSessionNotInitializedException();
    }
  }

  Future<void> stopSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.removeUserLocation();
    } on SessionNotInitializedException {
      throw GoogleNavigationStopSimulationSessionNotInitializedException();
    }
  }
}

@riverpod
GoogleNavigationRepository googleNavigationRepository(
  GoogleNavigationRepositoryRef ref,
) {
  return GoogleNavigationRepository();
}
