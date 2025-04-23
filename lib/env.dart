import 'dart:io';

/// spec: https://medium.com/@nayanbabariya/set-up-environment-variables-in-flutter-for-secure-and-scalable-apps-7409ae0c383e
/// spec: https://codewithandrea.com/tips/dart-define-from-file-env-json
class Env {
  /// View Google maps for Android
  static String get androidMapsApi =>
      const String.fromEnvironment('ANDROID_MAPS_API');

  /// View Google maps for iOS
  static String get iosMapsApi => const String.fromEnvironment('IOS_MAPS_API');

  /// Provides turn-by-turn directions to a single location
  static String get directionsApi =>
      const String.fromEnvironment('DIRECTIONS_API');

  /// Calculates the distance between multiple places, to more efficiently
  /// determine how long it'll take to go to each destination
  static String get distanceMatrixApi =>
      const String.fromEnvironment('DISTANCE_MATRIX_API');

  /// Combination of Directions + Distance Matrix APIs
  /// Designed to only request the info that you need, saving costs
  static String get routesApi => const String.fromEnvironment('ROUTES_API');

  /// Google Sign In client ID for iOS
  /// This is used to authenticate the user with Google services
  static String get iosGoogleClientId =>
      const String.fromEnvironment('IOS_GOOGLE_CLIENT_ID');

  /// Base Fhir URI
  /// This is used to connect to the Fhir server
  static String get fhirBaseUri =>
      const String.fromEnvironment('FHIR_BASE_URI');

  /// Service Account Email for testing purposes
  /// This is used instead of Google Sign In for testing
  static String get serviceAccountEmail =>
      const String.fromEnvironment('SERVICE_ACCOUNT_EMAIL');

  /// Service Account Private Key for testing purposes
  /// This can be a PEM format or base64-encoded key for iOS compatibility
  static String get serviceAccountPrivateKey =>
      const String.fromEnvironment('SERVICE_ACCOUNT_PRIVATE_KEY');

  /// Determine which Maps API key to show based on platform
  static String mapsApi() {
    if (Platform.isAndroid) {
      return Env.androidMapsApi;
    } else if (Platform.isIOS) {
      return Env.iosMapsApi;
    } else {
      throw UnsupportedError(
        'Current platform is not supported for Google Maps',
      );
    }
  }
}
