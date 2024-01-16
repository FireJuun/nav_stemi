import 'package:equatable/equatable.dart';

class GeocodedWaypoint extends Equatable {
  const GeocodedWaypoint({this.geocoderStatus, this.placeId, this.types});

  final String? geocoderStatus;
  final String? placeId;
  final List<String>? types;

  factory GeocodedWaypoint.fromJson(Map<String, Object?> json) {
    return GeocodedWaypoint(
      geocoderStatus: json['geocoder_status'] as String?,
      placeId: json['place_id'] as String?,
      types: json['types'] as List<String>?,
    );
  }

  Map<String, Object?> toJson() => {
        'geocoder_status': geocoderStatus,
        'place_id': placeId,
        'types': types,
      };

  GeocodedWaypoint copyWith({
    String? geocoderStatus,
    String? placeId,
    List<String>? types,
  }) {
    return GeocodedWaypoint(
      geocoderStatus: geocoderStatus ?? this.geocoderStatus,
      placeId: placeId ?? this.placeId,
      types: types ?? this.types,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [geocoderStatus, placeId, types];
}
