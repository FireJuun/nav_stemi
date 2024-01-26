import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:nav_stemi/src/features/navigate/domain/directions/distance.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/duration.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/end_location.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/polyline.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/start_location.dart';

class Step extends Equatable {
  const Step({
    this.distance,
    this.duration,
    this.endLocation,
    this.htmlInstructions,
    this.polyline,
    this.startLocation,
    this.travelMode,
  });

  factory Step.fromJson(Map<String, Object?> json) => Step(
        distance: json['distance'] == null
            ? null
            : Distance.fromJson(json['distance']! as Map<String, Object?>),
        duration: json['duration'] == null
            ? null
            : DirectionDuration.fromJson(
                json['duration']! as Map<String, Object?>),
        endLocation: json['end_location'] == null
            ? null
            : EndLocation.fromJson(
                json['end_location']! as Map<String, Object?>,
              ),
        htmlInstructions: json['html_instructions'] as String?,
        polyline: json['polyline'] == null
            ? null
            : PolylineX.fromJson(json['polyline']! as Map<String, Object?>),
        startLocation: json['start_location'] == null
            ? null
            : StartLocation.fromJson(
                json['start_location']! as Map<String, Object?>,
              ),
        travelMode: json['travel_mode'] as String?,
      );

  final Distance? distance;
  final DirectionDuration? duration;
  final EndLocation? endLocation;
  final String? htmlInstructions;
  final Polyline? polyline;
  final StartLocation? startLocation;
  final String? travelMode;

  Map<String, Object?> toJson() => {
        'distance': distance?.toJson(),
        'duration': duration?.toJson(),
        'end_location': endLocation?.toJson(),
        'html_instructions': htmlInstructions,
        'polyline': polyline?.toJson(),
        'start_location': startLocation?.toJson(),
        'travel_mode': travelMode,
      };

  Step copyWith({
    Distance? distance,
    DirectionDuration? duration,
    EndLocation? endLocation,
    String? htmlInstructions,
    Polyline? polyline,
    StartLocation? startLocation,
    String? travelMode,
  }) {
    return Step(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      endLocation: endLocation ?? this.endLocation,
      htmlInstructions: htmlInstructions ?? this.htmlInstructions,
      polyline: polyline ?? this.polyline,
      startLocation: startLocation ?? this.startLocation,
      travelMode: travelMode ?? this.travelMode,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      distance,
      duration,
      endLocation,
      htmlInstructions,
      polyline,
      startLocation,
      travelMode,
    ];
  }
}
