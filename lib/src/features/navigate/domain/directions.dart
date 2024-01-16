import 'package:equatable/equatable.dart';

import 'package:nav_stemi/src/features/navigate/domain/directions/geocoded_waypoint.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/route.dart';

class Directions extends Equatable {
  const Directions({this.geocodedWaypoints, this.routes, this.status});

  factory Directions.fromJson(Map<String, Object?> json) => Directions(
        geocodedWaypoints: (json['geocoded_waypoints'] as List<dynamic>?)
            ?.map((e) => GeocodedWaypoint.fromJson(e as Map<String, Object?>))
            .toList(),
        routes: (json['routes'] as List<dynamic>?)
            ?.map((e) => Route.fromJson(e as Map<String, Object?>))
            .toList(),
        status: json['status'] as String?,
      );

  final List<GeocodedWaypoint>? geocodedWaypoints;
  final List<Route>? routes;
  final String? status;

  Map<String, Object?> toJson() => {
        'geocoded_waypoints':
            geocodedWaypoints?.map((e) => e.toJson()).toList(),
        'routes': routes?.map((e) => e.toJson()).toList(),
        'status': status,
      };

  Directions copyWith({
    List<GeocodedWaypoint>? geocodedWaypoints,
    List<Route>? routes,
    String? status,
  }) {
    return Directions(
      geocodedWaypoints: geocodedWaypoints ?? this.geocodedWaypoints,
      routes: routes ?? this.routes,
      status: status ?? this.status,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [geocodedWaypoints, routes, status];
}
