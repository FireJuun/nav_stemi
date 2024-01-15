import 'dart:io';

import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'ANDROID_MAPS_API', obfuscate: true)
  static final String androidMapsApi = _Env.androidMapsApi;
  @EnviedField(varName: 'IOS_MAPS_API', obfuscate: true)
  static final String iosMapsApi = _Env.iosMapsApi;

  @EnviedField(varName: 'DIRECTIONS_API', obfuscate: true)
  static final String directionsApi = _Env.directionsApi;

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
