import 'package:equatable/equatable.dart';

class Polyline extends Equatable {
  const Polyline({this.points});

  final String? points;

  factory Polyline.fromJson(Map<String, Object?> json) => Polyline(
        points: json['points'] as String?,
      );

  Map<String, Object?> toJson() => {
        'points': points,
      };

  Polyline copyWith({
    String? points,
  }) {
    return Polyline(
      points: points ?? this.points,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [points];
}
