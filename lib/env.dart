import 'dart:io';

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  /// View Google maps for Android
  @EnviedField(varName: 'ANDROID_MAPS_API', obfuscate: true)
  static final String androidMapsApi = _Env.androidMapsApi;

  /// View Google maps for iOS
  @EnviedField(varName: 'IOS_MAPS_API', obfuscate: true)
  static final String iosMapsApi = _Env.iosMapsApi;

  /// Provides turn-by-turn directions to a single location
  @EnviedField(varName: 'DIRECTIONS_API', obfuscate: true)
  static final String directionsApi = _Env.directionsApi;

  /// Calculates the distance between multiple places, to more efficiently
  /// determine how long it'll take to go to each destination
  @EnviedField(varName: 'DISTANCE_MATRIX_API', obfuscate: true)
  static final String distanceMatrixApi = _Env.distanceMatrixApi;

  /// Combination of Directions + Distance Matrix APIs
  /// Designed to only request the info that you need, saving costs
  @EnviedField(varName: 'ROUTES_API', obfuscate: true)
  static final String routesApi = _Env.routesApi;

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
