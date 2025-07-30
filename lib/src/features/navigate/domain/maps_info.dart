// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

typedef MarkerId = String;
typedef PolylineId = String;

class MapsInfo extends Equatable {
  const MapsInfo({
    this.origin,
    this.destination,
    this.markers = const {},
    this.polylines = const {},
  });

  final AppWaypoint? origin;
  final AppWaypoint? destination;
  final Map<MarkerId, Marker> markers;
  final Map<PolylineId, Polyline> polylines;

  MapsInfo copyWith({
    AppWaypoint? origin,
    AppWaypoint? destination,
    Map<MarkerId, Marker>? markers,
    Map<PolylineId, Polyline>? polylines,
  }) {
    return MapsInfo(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'origin': origin?.toMap(),
      'destination': destination?.toMap(),
      'markers': markers,
      'polylines': polylines,
    };
  }

  factory MapsInfo.fromMap(Map<String, dynamic> map) {
    return MapsInfo(
      origin: map['origin'] != null
          ? AppWaypoint.fromMap(map['origin'] as Map<String, dynamic>)
          : null,
      destination: map['destination'] != null
          ? AppWaypoint.fromMap(map['destination'] as Map<String, dynamic>)
          : null,
      markers:
          Map<MarkerId, Marker>.from(map['markers'] as Map<MarkerId, dynamic>),
      polylines: Map<PolylineId, Polyline>.from(
        map['polylines'] as Map<PolylineId, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory MapsInfo.fromJson(String source) =>
      MapsInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [origin, destination, markers, polylines];
}
