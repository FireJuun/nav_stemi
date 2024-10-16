import 'dart:convert';

import 'package:equatable/equatable.dart';
// import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_routes_flutter/google_routes_flutter.dart' as routes;

/// Location class, with [latitude], [longitude],
/// and optional labels and silent calls
///
/// Latitude varies between -90.0 to +90.0
/// Longitude varies from -180.0 (inclusive) to +180.0 (exclusive)
///
/// Calculations to ensure these values follows logic from:
/// https://github.com/flutter/packages/blob/main/packages/google_maps_flutter/google_maps_flutter_platform_interface/lib/src/types/location.dart
class AppWaypoint extends Equatable {
  const AppWaypoint({
    required double latitude,
    required double longitude,
    this.label = '',
    this.isSilent = false,
  })  : latitude =
            latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude),
        // Avoid normalization to prevent loss of precision
        longitude = longitude >= -180 && longitude < 180
            ? longitude
            : (longitude + 180.0) % 360.0 - 180.0;

  factory AppWaypoint.fromMap(Map<String, dynamic> map) {
    return AppWaypoint(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      label: map['label'] as String,
      isSilent: map['isSilent'] as bool,
    );
  }

  factory AppWaypoint.fromJson(String source) =>
      AppWaypoint.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Conversions
  factory AppWaypoint.fromGoogleMaps(
    maps.LatLng latLng, {
    String label = '',
    bool isSilent = false,
  }) =>
      AppWaypoint(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        label: label,
        isSilent: isSilent,
      );

  factory AppWaypoint.fromGoogleRoutes(
    routes.LatLng latLng, {
    String label = '',
    bool isSilent = false,
  }) {
    assert(latLng.latitude != null, 'Error: latitude must not be null');
    assert(latLng.longitude != null, 'Error: longitude must not be null');

    return AppWaypoint(
      latitude: latLng.latitude!,
      longitude: latLng.longitude!,
      label: label,
      isSilent: isSilent,
    );
  }

  // TODO(FireJuun): Implement Mapbox conversion
  // factory AppWaypoint.fromMapbox(WayPoint waypoint) {
  //   assert(waypoint.latitude != null, 'Error: latitude must not be null');
  //   assert(waypoint.longitude != null, 'Error: longitude must not be null');

  //   return AppWaypoint(
  //     latitude: waypoint.latitude!,
  //     longitude: waypoint.longitude!,
  //     label: waypoint.name ?? '',
  //     isSilent: waypoint.isSilent ?? false,
  //   );
  // }

  final double latitude;
  final double longitude;
  final String label;
  final bool isSilent;

  @override
  List<Object> get props => [latitude, longitude, label, isSilent];

  AppWaypoint copyWith({
    double? latitude,
    double? longitude,
    String? label,
    bool? isSilent,
  }) {
    return AppWaypoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      isSilent: isSilent ?? this.isSilent,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
      'isSilent': isSilent,
    };
  }

  String toJson() => json.encode(toMap());

  routes.LatLng toGoogleRoutes() =>
      routes.LatLng(latitude: latitude, longitude: longitude);

  maps.LatLng toGoogleMaps() => maps.LatLng(latitude, longitude);

  // TODO(FireJuun): Implement Mapbox conversion
  // WayPoint toMapbox() => WayPoint(
  //       name: label,
  //       latitude: latitude,
  //       longitude: longitude,
  //       isSilent: isSilent,
  //     );

  @override
  bool get stringify => true;
}
