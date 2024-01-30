import 'package:equatable/equatable.dart';

class Northeast extends Equatable {
  const Northeast({this.lat, this.lng});

  factory Northeast.fromJson(Map<String, Object?> json) => Northeast(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  final double? lat;
  final double? lng;

  Map<String, Object?> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  Northeast copyWith({
    double? lat,
    double? lng,
  }) {
    return Northeast(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lat, lng];
}
