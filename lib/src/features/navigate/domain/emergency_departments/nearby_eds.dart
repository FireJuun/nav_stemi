// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:nav_stemi/nav_stemi.dart';

class NearbyEds extends Equatable {
  const NearbyEds({
    required this.items,
  });
  final Map<AppWaypoint, NearbyEd> items;

  NearbyEds copyWith({
    Map<AppWaypoint, NearbyEd>? items,
  }) {
    return NearbyEds(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items,
    };
  }

  factory NearbyEds.fromMap(Map<String, dynamic> map) {
    return NearbyEds(
      items: Map<AppWaypoint, NearbyEd>.from(
        map['items'] as Map<AppWaypoint, NearbyEd>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory NearbyEds.fromJson(String source) =>
      NearbyEds.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [items];
}

/// Helper extension to sort the [NearbyEds] by distance from current location.
extension NearbyEdsX on NearbyEds {
  List<NearbyEd> get sortedByDistance {
    final sorted = items.values.toList()
      ..sort((a, b) => a.distanceBetween.compareTo(b.distanceBetween));
    return sorted;
  }

  List<NearbyEd> get sortedByRouteDuration {
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
    return sorted;
  }
}
