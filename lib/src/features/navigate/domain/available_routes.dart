import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class AvailableRoutes extends Equatable {
  const AvailableRoutes({
    required this.origin,
    required this.destination,
    required this.destinationInfo,
    required this.requestedDateTime,
    this.routes,
  });

  final maps.LatLng origin;
  final maps.LatLng destination;
  final EdInfo destinationInfo;
  final DateTime requestedDateTime;

  final List<Route>? routes;

  AvailableRoutes copyWith({
    maps.LatLng? origin,
    maps.LatLng? destination,
    EdInfo? destinationInfo,
    DateTime? requestedDateTime,
    List<Route>? routes,
  }) {
    return AvailableRoutes(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      destinationInfo: destinationInfo ?? this.destinationInfo,
      requestedDateTime: requestedDateTime ?? this.requestedDateTime,
      routes: routes ?? this.routes,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [origin, destination, destinationInfo, requestedDateTime, routes];
}
