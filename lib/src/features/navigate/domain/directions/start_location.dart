import 'package:equatable/equatable.dart';

class StartLocation extends Equatable {
  const StartLocation({this.lat, this.lng});

  final double? lat;
  final double? lng;

  factory StartLocation.fromJson(Map<String, Object?> json) => StartLocation(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  Map<String, Object?> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  StartLocation copyWith({
    double? lat,
    double? lng,
  }) {
    return StartLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lat, lng];
}
