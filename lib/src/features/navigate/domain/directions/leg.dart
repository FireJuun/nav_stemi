import 'package:equatable/equatable.dart';

import 'distance.dart';
import 'duration.dart';
import 'end_location.dart';
import 'start_location.dart';
import 'step.dart';

class Leg extends Equatable {
  const Leg({
    this.distance,
    this.duration,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
    this.steps,
    this.trafficSpeedEntry,
    this.viaWaypoint,
  });

  final Distance? distance;
  final Duration? duration;
  final String? endAddress;
  final EndLocation? endLocation;
  final String? startAddress;
  final StartLocation? startLocation;
  final List<Step>? steps;
  final List<dynamic>? trafficSpeedEntry;
  final List<dynamic>? viaWaypoint;

  factory Leg.fromJson(Map<String, Object?> json) => Leg(
        distance: json['distance'] == null
            ? null
            : Distance.fromJson(json['distance']! as Map<String, Object?>),
        duration: json['duration'] == null
            ? null
            : Duration.fromJson(json['duration']! as Map<String, Object?>),
        endAddress: json['end_address'] as String?,
        endLocation: json['end_location'] == null
            ? null
            : EndLocation.fromJson(
                json['end_location']! as Map<String, Object?>),
        startAddress: json['start_address'] as String?,
        startLocation: json['start_location'] == null
            ? null
            : StartLocation.fromJson(
                json['start_location']! as Map<String, Object?>),
        steps: (json['steps'] as List<dynamic>?)
            ?.map((e) => Step.fromJson(e as Map<String, Object?>))
            .toList(),
        trafficSpeedEntry: json['traffic_speed_entry'] as List<dynamic>?,
        viaWaypoint: json['via_waypoint'] as List<dynamic>?,
      );

  Map<String, Object?> toJson() => {
        'distance': distance?.toJson(),
        'duration': duration?.toJson(),
        'end_address': endAddress,
        'end_location': endLocation?.toJson(),
        'start_address': startAddress,
        'start_location': startLocation?.toJson(),
        'steps': steps?.map((e) => e.toJson()).toList(),
        'traffic_speed_entry': trafficSpeedEntry,
        'via_waypoint': viaWaypoint,
      };

  Leg copyWith({
    Distance? distance,
    Duration? duration,
    String? endAddress,
    EndLocation? endLocation,
    String? startAddress,
    StartLocation? startLocation,
    List<Step>? steps,
    List<dynamic>? trafficSpeedEntry,
    List<dynamic>? viaWaypoint,
  }) {
    return Leg(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      endAddress: endAddress ?? this.endAddress,
      endLocation: endLocation ?? this.endLocation,
      startAddress: startAddress ?? this.startAddress,
      startLocation: startLocation ?? this.startLocation,
      steps: steps ?? this.steps,
      trafficSpeedEntry: trafficSpeedEntry ?? this.trafficSpeedEntry,
      viaWaypoint: viaWaypoint ?? this.viaWaypoint,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      distance,
      duration,
      endAddress,
      endLocation,
      startAddress,
      startLocation,
      steps,
      trafficSpeedEntry,
      viaWaypoint,
    ];
  }
}
