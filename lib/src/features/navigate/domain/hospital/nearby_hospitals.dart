// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:nav_stemi/nav_stemi.dart';

class NearbyHospitals extends Equatable {
  const NearbyHospitals({
    required this.items,
  });
  final Map<AppWaypoint, NearbyHospital> items;

  NearbyHospitals copyWith({
    Map<AppWaypoint, NearbyHospital>? items,
  }) {
    return NearbyHospitals(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items,
    };
  }

  factory NearbyHospitals.fromMap(Map<String, dynamic> map) {
    return NearbyHospitals(
      items: Map<AppWaypoint, NearbyHospital>.from(
        map['items'] as Map<AppWaypoint, NearbyHospital>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory NearbyHospitals.fromJson(String source) =>
      NearbyHospitals.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [items];
}

/// Helper extension to sort the [NearbyHospitals]
/// by distance from current location.
extension NearbyHospitalsX on NearbyHospitals {
  NearbyHospitals get sortedByDistance {
    final sorted = items.values.toList()
      ..sort((a, b) => a.distanceBetween.compareTo(b.distanceBetween));
    return copyWith(
      items: Map.fromEntries(
        sorted.map((e) => MapEntry(e.hospitalInfo.location(), e)),
      ),
    );
  }

  NearbyHospitals get sortedByRouteDuration {
    const routeDurationDto = RouteDurationDto();
    final sorted = items.values.toList()
      ..sort(
        (a, b) {
          final aDuration =
              routeDurationDto.routeDurationToSeconds(a.routeDuration) ??
                  Duration.zero;
          final bDuration =
              routeDurationDto.routeDurationToSeconds(b.routeDuration) ??
                  Duration.zero;
          return aDuration.compareTo(bDuration);
        },
      );

    return copyWith(
      items: Map.fromEntries(
        sorted.map((e) => MapEntry(e.hospitalInfo.location(), e)),
      ),
    );
  }
}
