import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Helper class to convert a [Position] to a [LatLng]
/// and vice versa.
///
/// DTO: Data Transfer Object
///

extension PositionX on Position {
  LatLng toLatLng() => LatLng(latitude, longitude);
  AppWaypoint toAppWaypoint() =>
      AppWaypoint(latitude: latitude, longitude: longitude);
}
