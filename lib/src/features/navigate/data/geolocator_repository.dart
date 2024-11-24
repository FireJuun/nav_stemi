import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_repository.g.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
///
/// source: https://pub.dev/packages/geolocator

class GeolocatorRepository {
  /// Stream of the current position of the device.
  /// The stream will emit the last known position of the device
  Stream<Position?> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  /// Get the current position of the device.
  ///
  Future<Position> getCurrentPosition() async {
    await checkLocationEnabled();

    return Geolocator.getCurrentPosition();
  }

  /// Get the last known position of the device.
  /// This is useful when the app is opened and the user
  /// has not moved since the last time the app was opened.
  ///
  /// If no position is available, the `Future` will return `null`.
  ///
  Future<Position?> getLastKnownPosition() async {
    await checkLocationEnabled();

    return Geolocator.getLastKnownPosition();
  }

  double getDistanceBetween(
    Position currentLocation,
    LatLng destination,
  ) =>
      Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        destination.latitude,
        destination.longitude,
      );

  /// Check location permissions and services.
  /// If the user has not granted location permission, the app will request it.
  /// If the user has denied location permission, the app will return an error.
  /// If the user has permanently denied location permission, the app will return an error.
  /// If the location services are disabled, the app will return an error.
  ///
  /// source: https://pub.dev/packages/geolocator
  Future<bool> checkLocationEnabled() async {
    // TODO(FireJuun): should we use this package or permissions package for this?
    /// likely, either one can work...
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

@riverpod
Stream<Position?> watchPosition(WatchPositionRef ref) {
  final geolocatorRepository = ref.watch(geolocatorRepositoryProvider);
  return geolocatorRepository.watchPosition();
}

@riverpod
Future<Position> getCurrentPosition(GetCurrentPositionRef ref) {
  final geolocatorRepository = ref.watch(geolocatorRepositoryProvider);
  return geolocatorRepository.getCurrentPosition();
}

@riverpod
Future<Position?> getLastKnownPosition(GetLastKnownPositionRef ref) {
  final geolocatorRepository = ref.watch(geolocatorRepositoryProvider);
  return geolocatorRepository.getLastKnownPosition();
}

/// Get the last known position of the device, if available.
/// Otherwise, get the current position of the device, which
/// forces the device to get the current location and may take
/// longer to return a result.
@riverpod
Future<Position> getLastKnownOrCurrentPosition(
  GetLastKnownOrCurrentPositionRef ref,
) async {
  final lastKnownPosition =
      await ref.watch(getLastKnownPositionProvider.future);

  if (lastKnownPosition != null) {
    return lastKnownPosition;
  }

  return ref.watch(getCurrentPositionProvider.future);
}
