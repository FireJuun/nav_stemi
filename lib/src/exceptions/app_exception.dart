import 'package:nav_stemi/nav_stemi.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
/// Base class for client-side errors
sealed class AppException implements Exception {
  AppException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Auth
class LoginProcessCancelledException extends AppException {
  LoginProcessCancelledException()
      : super('login-process-cancelled', 'Login process cancelled'.hardcoded);
}

class LoginFailedException extends AppException {
  LoginFailedException() : super('login-failed', 'Login failed'.hardcoded);
}

class LogoutFailedException extends AppException {
  LogoutFailedException() : super('logout-failed', 'Logout failed'.hardcoded);
}

/// Route Exceptions
class RouteInformationNotAvailableException extends AppException {
  RouteInformationNotAvailableException()
      : super(
          'route-information-not-available',
          'Route information not available'.hardcoded,
        );
}

class NextClosestRouteNotAvailableException extends AppException {
  NextClosestRouteNotAvailableException()
      : super(
          'no-next-closest-route-available',
          'No next closest route available'.hardcoded,
        );
}

class ConvertMetersToMilesException extends AppException {
  ConvertMetersToMilesException()
      : super(
          'convert-meters-to-miles-failed',
          'Unable to convert distance from meters to miles'.hardcoded,
        );
}

class NoNearbyEdsAvailableException extends AppException {
  NoNearbyEdsAvailableException()
      : super('no-nearby-eds-available', 'No nearby EDS available'.hardcoded);
}

class NoPCICentersAvailableException extends AppException {
  NoPCICentersAvailableException()
      : super('no-pci-centers-available', 'No PCI centers available'.hardcoded);
}

/// Google Navigation Exceptions
/// route status enums available here:
/// https://github.com/googlemaps/flutter-navigation-sdk/blob/main/lib/src/types/navigation_destinations.dart
///
/// error messages from here:
/// https://github.com/googlemaps/flutter-navigation-sdk/blob/b3b5266d815561debb7ff90c70945cc0eaa8f997/example/lib/pages/navigation.dart#L729
class GoogleNavigationInternalErrorException extends AppException {
  GoogleNavigationInternalErrorException()
      : super(
          'google-navigation-internal-error',
          'Unexpected internal error occured. Please restart the app.'
              .hardcoded,
        );
}

class GoogleNavigationRouteNotFoundException extends AppException {
  GoogleNavigationRouteNotFoundException()
      : super(
          'google-navigation-route-not-found',
          'The route could not be calculated.'.hardcoded,
        );
}

class GoogleNavigationNetworkErrorException extends AppException {
  GoogleNavigationNetworkErrorException()
      : super(
          'google-navigation-network-error',
          'Working network connection is required to calculate the route.'
              .hardcoded,
        );
}

class GoogleNavigationQuotaExceededException extends AppException {
  GoogleNavigationQuotaExceededException()
      : super(
          'google-navigation-quota-exceeded',
          'Insufficient API quota to use the navigation.'.hardcoded,
        );
}

class GoogleNavigationQuotaCheckFailedException extends AppException {
  GoogleNavigationQuotaCheckFailedException()
      : super(
          'google-navigation-quota-check-failed',
          'API quota check failed, cannot authorize the navigation.'.hardcoded,
        );
}

class GoogleNavigationApiKeyNotAuthorizedException extends AppException {
  GoogleNavigationApiKeyNotAuthorizedException()
      : super(
          'google-navigation-api-key-not-authorized',
          'The API key is not authorized to use the navigation.'.hardcoded,
        );
}

class GoogleNavigationStatusCanceledException extends AppException {
  GoogleNavigationStatusCanceledException()
      : super(
          'google-navigation-status-canceled',
          'The route calculation was canceled.'.hardcoded,
        );
}

class GoogleNavigationDuplicateWaypointsErrorException extends AppException {
  GoogleNavigationDuplicateWaypointsErrorException()
      : super(
          'google-navigation-duplicate-waypoints',
          'The route could not be calculated because of duplicate waypoints.'
              .hardcoded,
        );
}

class GoogleNavigationNoWaypointsErrorException extends AppException {
  GoogleNavigationNoWaypointsErrorException()
      : super(
          'google-navigation-no-waypoints',
          '''The route could not be calculated because no waypoints were provided.'''
              .hardcoded,
        );
}

class GoogleNavigationLocationUnavailableException extends AppException {
  GoogleNavigationLocationUnavailableException()
      : super(
          'google-navigation-location-unavailable',
          'No user location is available. Did you allow location permission?'
              .hardcoded,
        );
}

class GoogleNavigationWaypointErrorException extends AppException {
  GoogleNavigationWaypointErrorException()
      : super(
          'google-navigation-waypoint-error',
          'Invalid waypoints provided.'.hardcoded,
        );
}

class GoogleNavigationTravelModeUnsupportedException extends AppException {
  GoogleNavigationTravelModeUnsupportedException()
      : super(
          'google-navigation-travel-mode-unsupported',
          'The route could not calculated for the given travel mode.'.hardcoded,
        );
}

class GoogleNavigationUnknownException extends AppException {
  GoogleNavigationUnknownException()
      : super(
          'google-navigation-unknown-error',
          'The route could not be calculated due to an unknown error.'
              .hardcoded,
        );
}

class GoogleNavigationLocationUnknownException extends AppException {
  GoogleNavigationLocationUnknownException()
      : super(
          'google-navigation-location-unknown',
          '''The route could not be calculated, because the user location is unknown.'''
              .hardcoded,
        );
}

class GoogleNavigationRouteTokenMalformedException extends AppException {
  GoogleNavigationRouteTokenMalformedException()
      : super(
          'route-token-malformed',
          'The route token is malformed.'.hardcoded,
        );
}

class GoogleNavigationResetTermsAndConditionsException extends AppException {
  GoogleNavigationResetTermsAndConditionsException()
      : super(
          'google-navigation-reset-terms-and-conditions',
          '''Cannot reset the terms after the navigation session has already been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationSetDestinationSessionNotInitializedException
    extends AppException {
  GoogleNavigationSetDestinationSessionNotInitializedException()
      : super(
          'set-destination-session-not-initialized',
          '''Cannot set the destination before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationClearDestinationSessionNotInitializedException
    extends AppException {
  GoogleNavigationClearDestinationSessionNotInitializedException()
      : super(
          'clear-destination-session-not-initialized',
          '''Cannot clear the destination before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationSetUserLocationSessionNotInitializedException
    extends AppException {
  GoogleNavigationSetUserLocationSessionNotInitializedException()
      : super(
          'set-user-location-session-not-initialized',
          '''Cannot set the user location before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationSimulateLocationsSessionNotInitializedException
    extends AppException {
  GoogleNavigationSimulateLocationsSessionNotInitializedException()
      : super(
          'simulate-locations-session-not-initialized',
          '''Cannot start the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationPauseSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavigationPauseSimulationSessionNotInitializedException()
      : super(
          'pause-simulation-session-not-initialized',
          '''Cannot pause the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationResumeSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavigationResumeSimulationSessionNotInitializedException()
      : super(
          'resume-simulation-session-not-initialized',
          '''Cannot resume the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationStopSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavigationStopSimulationSessionNotInitializedException()
      : super(
          'stop-simulation-session-not-initialized',
          '''Cannot stop the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationStartGuidanceSessionNotInitializedException
    extends AppException {
  GoogleNavigationStartGuidanceSessionNotInitializedException()
      : super(
          'start-guidance-session-not-initialized',
          '''Cannot start the guidance before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationStartGuidanceUnknownError extends AppException {
  GoogleNavigationStartGuidanceUnknownError()
      : super(
          'start-guidance-unknown-error',
          '''Cannot start the guidance. An unknown error occurred.'''.hardcoded,
        );
}

class GoogleNavigationStopGuidanceSessionNotInitializedException
    extends AppException {
  GoogleNavigationStopGuidanceSessionNotInitializedException()
      : super(
          'start-guidance-session-not-initialized',
          '''Cannot stop the guidance before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavigationStopGuidanceUnknownError extends AppException {
  GoogleNavigationStopGuidanceUnknownError()
      : super(
          'stop-guidance-unknown-error',
          '''Cannot stop the guidance. An unknown error occurred.'''.hardcoded,
        );
}

class GoogleNavigationSessionInitializationLocationPermissionMissingException
    extends AppException {
  GoogleNavigationSessionInitializationLocationPermissionMissingException()
      : super(
          'session-initialization-location-permission-missing',
          'No user location is available. Did you allow location permission?'
              .hardcoded,
        );
}

class GoogleNavigationSessionInitializationTermsNotAcceptedException
    extends AppException {
  GoogleNavigationSessionInitializationTermsNotAcceptedException()
      : super(
          'session-initialization-terms-not-accepted',
          'Accept the terms and conditions dialog first.'.hardcoded,
        );
}

class GoogleNavigationSessionInitializationNotAuthorizedException
    extends AppException {
  GoogleNavigationSessionInitializationNotAuthorizedException()
      : super(
          'session-initialization-not-authorized',
          'Your API key is empty, invalid or not authorized to use Navigation.'
              .hardcoded,
        );
}
