import 'package:equatable/equatable.dart';

class Southwest extends Equatable {
  const Southwest({this.lat, this.lng});

  factory Southwest.fromJson(Map<String, Object?> json) => Southwest(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  final double? lat;
  final double? lng;

  Map<String, Object?> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  Southwest copyWith({
    double? lat,
    double? lng,
  }) {
    return Southwest(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [lat, lng];
}
