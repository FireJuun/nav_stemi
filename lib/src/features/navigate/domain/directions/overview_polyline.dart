import 'package:equatable/equatable.dart';

class OverviewPolyline extends Equatable {
  const OverviewPolyline({this.points});

  final String? points;

  factory OverviewPolyline.fromJson(Map<String, Object?> json) {
    return OverviewPolyline(
      points: json['points'] as String?,
    );
  }

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
