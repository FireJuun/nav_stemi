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
class GoogleNavInternalErrorException extends AppException {
  GoogleNavInternalErrorException()
      : super(
          'google-navigation-internal-error',
          'Unexpected internal error occured. Please restart the app.'
              .hardcoded,
        );
}

class GoogleNavRouteNotFoundException extends AppException {
  GoogleNavRouteNotFoundException()
      : super(
          'google-navigation-route-not-found',
          'The route could not be calculated.'.hardcoded,
        );
}

class GoogleNavNetworkErrorException extends AppException {
  GoogleNavNetworkErrorException()
      : super(
          'google-navigation-network-error',
          'Working network connection is required to calculate the route.'
              .hardcoded,
        );
}

class GoogleNavQuotaExceededException extends AppException {
  GoogleNavQuotaExceededException()
      : super(
          'google-navigation-quota-exceeded',
          'Insufficient API quota to use the navigation.'.hardcoded,
        );
}

class GoogleNavQuotaCheckFailedException extends AppException {
  GoogleNavQuotaCheckFailedException()
      : super(
          'google-navigation-quota-check-failed',
          'API quota check failed, cannot authorize the navigation.'.hardcoded,
        );
}

class GoogleNavApiKeyNotAuthorizedException extends AppException {
  GoogleNavApiKeyNotAuthorizedException()
      : super(
          'google-navigation-api-key-not-authorized',
          'The API key is not authorized to use the navigation.'.hardcoded,
        );
}

class GoogleNavStatusCanceledException extends AppException {
  GoogleNavStatusCanceledException()
      : super(
          'google-navigation-status-canceled',
          'The route calculation was canceled.'.hardcoded,
        );
}

class GoogleNavDuplicateWaypointsErrorException extends AppException {
  GoogleNavDuplicateWaypointsErrorException()
      : super(
          'google-navigation-duplicate-waypoints',
          'The route could not be calculated because of duplicate waypoints.'
              .hardcoded,
        );
}

class GoogleNavNoWaypointsErrorException extends AppException {
  GoogleNavNoWaypointsErrorException()
      : super(
          'google-navigation-no-waypoints',
          '''The route could not be calculated because no waypoints were provided.'''
              .hardcoded,
        );
}

class GoogleNavLocationUnavailableException extends AppException {
  GoogleNavLocationUnavailableException()
      : super(
          'google-navigation-location-unavailable',
          'No user location is available. Did you allow location permission?'
              .hardcoded,
        );
}

class GoogleNavWaypointErrorException extends AppException {
  GoogleNavWaypointErrorException()
      : super(
          'google-navigation-waypoint-error',
          'Invalid waypoints provided.'.hardcoded,
        );
}

class GoogleNavTravelModeUnsupportedException extends AppException {
  GoogleNavTravelModeUnsupportedException()
      : super(
          'google-navigation-travel-mode-unsupported',
          'The route could not calculated for the given travel mode.'.hardcoded,
        );
}

class GoogleNavUnknownException extends AppException {
  GoogleNavUnknownException()
      : super(
          'google-navigation-unknown-error',
          'The route could not be calculated due to an unknown error.'
              .hardcoded,
        );
}

class GoogleNavLocationUnknownException extends AppException {
  GoogleNavLocationUnknownException()
      : super(
          'google-navigation-location-unknown',
          '''The route could not be calculated, because the user location is unknown.'''
              .hardcoded,
        );
}

class GoogleNavRouteTokenMalformedException extends AppException {
  GoogleNavRouteTokenMalformedException()
      : super(
          'route-token-malformed',
          'The route token is malformed.'.hardcoded,
        );
}

class GoogleNavResetTermsAndConditionsException extends AppException {
  GoogleNavResetTermsAndConditionsException()
      : super(
          'google-navigation-reset-terms-and-conditions',
          '''Cannot reset the terms after the navigation session has already been initialized.'''
              .hardcoded,
        );
}

class GoogleNavSetDestinationSessionNotInitializedException
    extends AppException {
  GoogleNavSetDestinationSessionNotInitializedException()
      : super(
          'set-destination-session-not-initialized',
          '''Cannot set the destination before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavClearDestinationSessionNotInitializedException
    extends AppException {
  GoogleNavClearDestinationSessionNotInitializedException()
      : super(
          'clear-destination-session-not-initialized',
          '''Cannot clear the destination before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavSetUserLocationSessionNotInitializedException
    extends AppException {
  GoogleNavSetUserLocationSessionNotInitializedException()
      : super(
          'set-user-location-session-not-initialized',
          '''Cannot set the user location before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavSimulateLocationsSessionNotInitializedException
    extends AppException {
  GoogleNavSimulateLocationsSessionNotInitializedException()
      : super(
          'simulate-locations-session-not-initialized',
          '''Cannot start the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavPauseSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavPauseSimulationSessionNotInitializedException()
      : super(
          'pause-simulation-session-not-initialized',
          '''Cannot pause the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavResumeSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavResumeSimulationSessionNotInitializedException()
      : super(
          'resume-simulation-session-not-initialized',
          '''Cannot resume the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavStopSimulationSessionNotInitializedException
    extends AppException {
  GoogleNavStopSimulationSessionNotInitializedException()
      : super(
          'stop-simulation-session-not-initialized',
          '''Cannot stop the simulation before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavStartGuidanceSessionNotInitializedException
    extends AppException {
  GoogleNavStartGuidanceSessionNotInitializedException()
      : super(
          'start-guidance-session-not-initialized',
          '''Cannot start the guidance before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavStartGuidanceUnknownError extends AppException {
  GoogleNavStartGuidanceUnknownError()
      : super(
          'start-guidance-unknown-error',
          '''Cannot start the guidance. An unknown error occurred.'''.hardcoded,
        );
}

class GoogleNavStopGuidanceSessionNotInitializedException extends AppException {
  GoogleNavStopGuidanceSessionNotInitializedException()
      : super(
          'start-guidance-session-not-initialized',
          '''Cannot stop the guidance before the navigation session has been initialized.'''
              .hardcoded,
        );
}

class GoogleNavStopGuidanceUnknownError extends AppException {
  GoogleNavStopGuidanceUnknownError()
      : super(
          'stop-guidance-unknown-error',
          '''Cannot stop the guidance. An unknown error occurred.'''.hardcoded,
        );
}

class LocationPermissionMissingException extends AppException {
  LocationPermissionMissingException()
      : super(
          'session-initialization-location-permission-missing',
          'No user location is available. Did you allow location permission?'
              .hardcoded,
        );
}

class NotificationPermissionMissingException extends AppException {
  NotificationPermissionMissingException()
      : super(
          'session-initialization-notification-permission-missing',
          '''Notifications are not available. Did you allow notification permissions?'''
              .hardcoded,
        );
}

class GoogleNavInitializationTermsNotAcceptedException extends AppException {
  GoogleNavInitializationTermsNotAcceptedException()
      : super(
          'session-initialization-terms-not-accepted',
          'Accept the terms and conditions dialog first.'.hardcoded,
        );
}

class GoogleNavInitializationNotAuthorizedException extends AppException {
  GoogleNavInitializationNotAuthorizedException()
      : super(
          'session-initialization-not-authorized',
          'Your API key is empty, invalid or not authorized to use Navigation.'
              .hardcoded,
        );
}
