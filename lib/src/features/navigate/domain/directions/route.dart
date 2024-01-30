import 'package:equatable/equatable.dart';

import 'package:nav_stemi/src/features/navigate/domain/directions/bounds.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/leg.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/overview_polyline.dart';

class Route extends Equatable {
  const Route({
    this.bounds,
    this.copyrights,
    this.legs,
    this.overviewPolyline,
    this.summary,
    this.warnings,
    this.waypointOrder,
  });

  factory Route.fromJson(Map<String, Object?> json) => Route(
        bounds: json['bounds'] == null
            ? null
            : Bounds.fromJson(json['bounds']! as Map<String, Object?>),
        copyrights: json['copyrights'] as String?,
        legs: (json['legs'] as List<dynamic>?)
            ?.map((e) => Leg.fromJson(e as Map<String, Object?>))
            .toList(),
        overviewPolyline: json['overview_polyline'] == null
            ? null
            : OverviewPolyline.fromJson(
                json['overview_polyline']! as Map<String, Object?>,
              ),
        summary: json['summary'] as String?,
        warnings: json['warnings'] as List<dynamic>?,
        waypointOrder: json['waypoint_order'] as List<int>?,
      );

  final Bounds? bounds;
  final String? copyrights;
  final List<Leg>? legs;
  final OverviewPolyline? overviewPolyline;
  final String? summary;
  final List<dynamic>? warnings;
  final List<int>? waypointOrder;

  Map<String, Object?> toJson() => {
        'bounds': bounds?.toJson(),
        'copyrights': copyrights,
        'legs': legs?.map((e) => e.toJson()).toList(),
        'overview_polyline': overviewPolyline?.toJson(),
        'summary': summary,
        'warnings': warnings,
        'waypoint_order': waypointOrder,
      };

  Route copyWith({
    Bounds? bounds,
    String? copyrights,
    List<Leg>? legs,
    OverviewPolyline? overviewPolyline,
    String? summary,
    List<dynamic>? warnings,
    List<int>? waypointOrder,
  }) {
    return Route(
      bounds: bounds ?? this.bounds,
      copyrights: copyrights ?? this.copyrights,
      legs: legs ?? this.legs,
      overviewPolyline: overviewPolyline ?? this.overviewPolyline,
      summary: summary ?? this.summary,
      warnings: warnings ?? this.warnings,
      waypointOrder: waypointOrder ?? this.waypointOrder,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      bounds,
      copyrights,
      legs,
      overviewPolyline,
      summary,
      warnings,
      waypointOrder,
    ];
  }
}
