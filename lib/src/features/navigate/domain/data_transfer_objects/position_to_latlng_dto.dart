import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class to convert a [Position] to a [LatLng]
/// and vice versa.
///
/// DTO: Data Transfer Object
///
class PositionToLatLngDTO {
  const PositionToLatLngDTO();

  /// Convert a [Position] to a [LatLng].
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Convert a [LatLng] to a [Position].
  Position latLngToPosition(LatLng latLng) => Position(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}
