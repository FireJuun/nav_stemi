import 'package:equatable/equatable.dart';

import 'package:nav_stemi/src/features/navigate/domain/directions/northeast.dart';
import 'package:nav_stemi/src/features/navigate/domain/directions/southwest.dart';

class Bounds extends Equatable {
  const Bounds({this.northeast, this.southwest});

  factory Bounds.fromJson(Map<String, Object?> json) => Bounds(
        northeast: json['northeast'] == null
            ? null
            : Northeast.fromJson(json['northeast']! as Map<String, Object?>),
        southwest: json['southwest'] == null
            ? null
            : Southwest.fromJson(json['southwest']! as Map<String, Object?>),
      );

  final Northeast? northeast;
  final Southwest? southwest;

  Map<String, Object?> toJson() => {
        'northeast': northeast?.toJson(),
        'southwest': southwest?.toJson(),
      };

  Bounds copyWith({
    Northeast? northeast,
    Southwest? southwest,
  }) {
    return Bounds(
      northeast: northeast ?? this.northeast,
      southwest: southwest ?? this.southwest,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [northeast, southwest];
}
