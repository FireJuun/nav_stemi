// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

import 'package:nav_stemi/nav_stemi.dart';

class NearbyEds extends Equatable {
  const NearbyEds({
    required this.items,
  });
  final Map<maps.LatLng, NearbyEd> items;

  NearbyEds copyWith({
    Map<maps.LatLng, NearbyEd>? items,
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
      items: Map<maps.LatLng, NearbyEd>.from(
        map['items'] as Map<maps.LatLng, NearbyEd>,
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
    final routeDurationDto = RouteDurationToSecondsDto();
    final sorted = items.values.toList()
      ..sort(
        (a, b) =>
            routeDurationDto.routeDurationToSeconds(a.routeDuration).compareTo(
                  routeDurationDto.routeDurationToSeconds(b.routeDuration),
                ),
      );
    return sorted;
  }
}
