import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_navigation_service.g.dart';

class GoogleNavigationService {
  const GoogleNavigationService(this.ref);

  final Ref ref;

  GoogleNavigationRepository get googleNavigationRepository =>
      ref.read(googleNavigationRepositoryProvider);
  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);

  Future<void> initialize() async {
    await checkTermsAccepted();
    await geolocatorRepository.checkLocationEnabled();
    await checkSessionInitialized();
  }

  @visibleForTesting
  Future<void> checkTermsAccepted() async {
    if (!await googleNavigationRepository.areTermsAccepted()) {
      final accepted = await showTermsAndConditionsDialog();
      if (!accepted) {
        throw GoogleNavigationSessionInitializationTermsNotAcceptedException();
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
      throw GoogleNavigationResetTermsAndConditionsException();
    }
  }

  @visibleForTesting
  Future<void> checkSessionInitialized() async {
    if (!await googleNavigationRepository.isInitialized()) {
      await initializeNavigationSession();
    }
  }

  @visibleForTesting
  Future<void> initializeNavigationSession() async {
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
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

  Future<void> cleanup() async {
    await googleNavigationRepository.cleanupNavigationSession();
  }

  Future<RouteCalculated> setDestinations(EdInfo edInfo) async {
    final latitude = edInfo.location.latitude;
    final longitude = edInfo.location.longitude;

    final destinations = Destinations(
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
          await googleNavigationRepository.setDestinations(destinations);

      switch (navRouteStatus) {
        case NavigationRouteStatus.statusOk:
          await startGuidance();
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
      await googleNavigationRepository.clearDestinations();
      return false;
    } on SessionNotInitializedException {
      throw GoogleNavigationClearDestinationSessionNotInitializedException();
    }
  }

  Future<GuidanceRunning> startGuidance() async {
    try {
      await googleNavigationRepository.startGuidance();
      if (await googleNavigationRepository.isGuidanceRunning()) {
        return true;
      }
      throw GoogleNavigationStartGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavigationStartGuidanceSessionNotInitializedException();
    }
  }

  Future<GuidanceRunning> stopGuidance() async {
    try {
      await googleNavigationRepository.stopGuidance();
      if (!await googleNavigationRepository.isGuidanceRunning()) {
        return false;
      }
      throw GoogleNavigationStopGuidanceUnknownError();
    } on SessionNotInitializedException {
      throw GoogleNavigationStopGuidanceSessionNotInitializedException();
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
      throw GoogleNavigationSetUserLocationSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRoute() async {
    try {
      await googleNavigationRepository.simulateLocationsAlongExistingRoute();
    } on SessionNotInitializedException {
      throw GoogleNavigationSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  ) async {
    try {
      await googleNavigationRepository
          .simulateLocationsAlongExistingRouteWithOptions(options);
    } on SessionNotInitializedException {
      throw GoogleNavigationSimulateLocationsSessionNotInitializedException();
    }
  }

  Future<void> pauseSimulation() async {
    try {
      await googleNavigationRepository.pauseSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavigationPauseSimulationSessionNotInitializedException();
    }
  }

  Future<void> resumeSimulation() async {
    try {
      await googleNavigationRepository.resumeSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavigationResumeSimulationSessionNotInitializedException();
    }
  }

  Future<void> stopSimulation() async {
    try {
      await googleNavigationRepository.stopSimulation();
    } on SessionNotInitializedException {
      throw GoogleNavigationStopSimulationSessionNotInitializedException();
    }
  }
}

@Riverpod(keepAlive: true)
GoogleNavigationService googleNavigationService(
  GoogleNavigationServiceRef ref,
) {
  return GoogleNavigationService(ref);
}
