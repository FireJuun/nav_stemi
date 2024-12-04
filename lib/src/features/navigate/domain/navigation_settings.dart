// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

typedef AudioGuidanceType = NavigationAudioGuidanceType;

class NavigationSettings {
  const NavigationSettings({
    this.showNorthUp = false,
    this.audioGuidanceType = AudioGuidanceType.alertsAndGuidance,
    this.shouldSimulateLocation = false,
    this.simulationSpeedMultiplier = 3.0,
    // TODO(FireJuun): re-enable null location handling
    this.simulationStartingLocation = randolphEms,
  });

  final bool showNorthUp;
  final AudioGuidanceType audioGuidanceType;
  final bool shouldSimulateLocation;
  final double simulationSpeedMultiplier;
  final AppWaypoint simulationStartingLocation;

  /// Only the [simulationStartingLocation] needs [ValueGetter],
  /// since it is the only nullable field.
  ///
  NavigationSettings copyWith({
    bool? showNorthUp,
    AudioGuidanceType? audioGuidanceType,
    bool? shouldSimulateLocation,
    double? simulationSpeedMultiplier,
    ValueGetter<AppWaypoint>? simulationStartingLocation,
  }) {
    return NavigationSettings(
      showNorthUp: showNorthUp ?? this.showNorthUp,
      audioGuidanceType: audioGuidanceType ?? this.audioGuidanceType,
      shouldSimulateLocation:
          shouldSimulateLocation ?? this.shouldSimulateLocation,
      simulationSpeedMultiplier:
          simulationSpeedMultiplier ?? this.simulationSpeedMultiplier,
      simulationStartingLocation: simulationStartingLocation != null
          ? simulationStartingLocation()
          : this.simulationStartingLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showNorthUp': showNorthUp,
      'audioGuidanceType': audioGuidanceType.toMap(audioGuidanceType),
      'shouldSimulateLocation': shouldSimulateLocation,
      'simulationSpeedMultiplier': simulationSpeedMultiplier,
      'simulationStartingLocation': simulationStartingLocation.toMap(),
    };
  }

  factory NavigationSettings.fromMap(Map<String, dynamic> map) {
    /// [a] is only used to access the [fromMap()] extension method.
    /// AudioGuidanceType.silent is never directly referenced.
    /// This not the cleanest way to do this, but I couldn't get
    /// extension types to work properly to solve this.
    const a = AudioGuidanceType.silent;

    return NavigationSettings(
      showNorthUp: map['showNorthUp'] as bool,
      audioGuidanceType: a.fromMap(
        map['audioGuidanceType'] as Map<String, dynamic>,
      ),
      shouldSimulateLocation: map['shouldSimulateLocation'] as bool,
      simulationSpeedMultiplier: map['simulationSpeedMultiplier'] as double,
      simulationStartingLocation: AppWaypoint.fromMap(
        map['simulationStartingLocation'] as Map<String, dynamic>,
      ),
      // TODO(FireJuun): re-enable null location handling
      // simulationStartingLocation: map['simulationStartingLocation'] != null
      //     ? AppWaypoint.fromMap(
      //         map['simulationStartingLocation'] as Map<String, dynamic>,
      //       )
      //     : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NavigationSettings.fromJson(String source) =>
      NavigationSettings.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '''NavigationSettings(showNorthUp: $showNorthUp, audioGuidanceType: $audioGuidanceType, shouldSimulateLocation: $shouldSimulateLocation, simulationSpeedMultiplier: $simulationSpeedMultiplier, simulationStartingLocation: $simulationStartingLocation)''';
  }
}

/// Converts enum values to and from map values.
extension AudioGuidanceTypeX on AudioGuidanceType {
  AudioGuidanceType fromMap(Map<String, dynamic> map) {
    switch (map['audioGuidanceType'] as String) {
      case 'alertsAndGuidance':
        return AudioGuidanceType.alertsAndGuidance;
      case 'alertsOnly':
        return AudioGuidanceType.alertsOnly;
      case 'silent':
        return AudioGuidanceType.silent;
      default:
        throw ArgumentError.value(
          map['audioGuidanceType'],
          'audioGuidanceType',
          'Invalid value',
        );
    }
  }

  Map<String, dynamic> toMap(AudioGuidanceType audioGuidanceType) {
    return {'audioGuidanceType': toString()};
  }

  String shortName() {
    switch (this) {
      case AudioGuidanceType.alertsAndGuidance:
        return 'Alerts & Guidance';
      case AudioGuidanceType.alertsOnly:
        return 'Alerts Only';
      case AudioGuidanceType.silent:
        return 'Silent';
    }
  }
}
