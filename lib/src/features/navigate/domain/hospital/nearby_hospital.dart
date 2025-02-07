import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:units_converter/units_converter.dart';

class NearbyHospital extends Equatable {
  const NearbyHospital({
    required this.distanceBetween,
    required this.routeDistance,
    required this.routeDuration,
    required this.hospitalInfo,
  });

  factory NearbyHospital.fromMap(Map<String, dynamic> map) {
    return NearbyHospital(
      distanceBetween: map['distanceBetween'] as double,
      routeDistance: map['routeDistance'] as int?,
      routeDuration: map['routeDuration'] as String?,
      hospitalInfo:
          Hospital.fromMap(map['hospitalInfo'] as Map<String, dynamic>),
    );
  }

  factory NearbyHospital.fromJson(String source) =>
      NearbyHospital.fromMap(json.decode(source) as Map<String, dynamic>);

  final double distanceBetween;
  final int? routeDistance;
  final String? routeDuration;
  final Hospital hospitalInfo;

  NearbyHospital copyWith({
    double? distanceBetween,
    int? routeDistance,
    String? routeDuration,
    Hospital? hospitalInfo,
  }) {
    return NearbyHospital(
      distanceBetween: distanceBetween ?? this.distanceBetween,
      routeDistance: routeDistance ?? this.routeDistance,
      routeDuration: routeDuration ?? this.routeDuration,
      hospitalInfo: hospitalInfo ?? this.hospitalInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distanceBetween': distanceBetween,
      'routeDistance': routeDistance,
      'routeDuration': routeDuration,
      'hospitalInfo': hospitalInfo.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [distanceBetween, routeDistance, routeDuration, hospitalInfo];

  double get distanceBetweenInMiles {
    final length = Length(removeTrailingZeros: false)
      ..convert(LENGTH.meters, distanceBetween);
    final lengthInMiles = length.miles.value;
    if (lengthInMiles == null) {
      throw ConvertMetersToMilesException();
    }
    return lengthInMiles;
  }
}
