import 'package:equatable/equatable.dart';

class OverviewPolyline extends Equatable {
  const OverviewPolyline({this.points});

  factory OverviewPolyline.fromJson(Map<String, Object?> json) {
    return OverviewPolyline(
      points: json['points'] as String?,
    );
  }

  final String? points;

  Map<String, Object?> toJson() => {
        'points': points,
      };

  OverviewPolyline copyWith({
    String? points,
  }) {
    return OverviewPolyline(
      points: points ?? this.points,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [points];
}
