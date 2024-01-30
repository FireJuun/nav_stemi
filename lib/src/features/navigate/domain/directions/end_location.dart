import 'package:equatable/equatable.dart';

class EndLocation extends Equatable {
  const EndLocation({this.lat, this.lng});

  factory EndLocation.fromJson(Map<String, Object?> json) => EndLocation(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  final double? lat;
  final double? lng;

  Map<String, Object?> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  EndLocation copyWith({
    double? lat,
    double? lng,
  }) {
    return EndLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lat, lng];
}
