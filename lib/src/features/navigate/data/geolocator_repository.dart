import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_repository.g.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
///
/// source: https://pub.dev/packages/geolocator

class GeolocatorRepository {
  /// Get the current position of the device.
  ///
  Future<Position> determinePosition() async {
    await checkPermissions();

    return Geolocator.getCurrentPosition();
  }

  /// Get the last known position of the device.
  /// This is useful when the app is opened and the user
  /// has not moved since the last time the app was opened.
  ///
  /// If no position is available, the `Future` will return `null`.
  ///
  Future<Position?> lastKnownPosition() async {
    await checkPermissions();

    return Geolocator.getLastKnownPosition();
  }

  /// Check location permissions and services.
  /// If the user has not granted location permission, the app will request it.
  /// If the user has denied location permission, the app will return an error.
  /// If the user has permanently denied location permission, the app will return an error.
  /// If the location services are disabled, the app will return an error.
  ///
  /// source: https://pub.dev/packages/geolocator
  @visibleForTesting
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    /// Permissions are granted
    return true;
  }
}

@Riverpod(keepAlive: true)
GeolocatorRepository geolocatorRepository(GeolocatorRepositoryRef ref) {
  return GeolocatorRepository();
}
