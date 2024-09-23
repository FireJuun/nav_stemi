import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NearbyEd extends Equatable {
  const NearbyEd({
    required this.distanceBetween,
    required this.routeDistance,
    required this.routeDuration,
    required this.edInfo,
  });

  factory NearbyEd.fromMap(Map<String, dynamic> map) {
    return NearbyEd(
      distanceBetween: map['distanceBetween'] as double,
      routeDistance: map['routeDistance'] as int?,
      routeDuration: map['routeDuration'] as String?,
      edInfo: EdInfo.fromMap(map['edInfo'] as Map<String, dynamic>),
    );
  }

  factory NearbyEd.fromJson(String source) =>
      NearbyEd.fromMap(json.decode(source) as Map<String, dynamic>);

  final double distanceBetween;
  final int? routeDistance;
  final String? routeDuration;
  final EdInfo edInfo;

  NearbyEd copyWith({
    double? distanceBetween,
    int? routeDistance,
    String? routeDuration,
    EdInfo? edInfo,
  }) {
    return NearbyEd(
      distanceBetween: distanceBetween ?? this.distanceBetween,
      routeDistance: routeDistance ?? this.routeDistance,
      routeDuration: routeDuration ?? this.routeDuration,
      edInfo: edInfo ?? this.edInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'distanceBetween': distanceBetween,
      'routeDistance': routeDistance,
      'routeDuration': routeDuration,
      'edInfo': edInfo.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [distanceBetween, routeDistance, routeDuration, edInfo];
}
