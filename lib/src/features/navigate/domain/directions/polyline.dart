import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

extension PolylineX on Polyline {
  static Polyline fromJson(Map<String, Object?> json) => Polyline(
        polylineId: json['polylineId']! as PolylineId? ??
            PolylineId(const Uuid().toString()),
        points: json['points'] as List<LatLng>? ?? [],
      );

  // TODO(FireJuun): don't think this is necessary
  // static Map<String, Object?> toJson() => {
  //       'points': points,
  //     };

  // static Polyline copyWith({
  //   PolylineId? polylineId,
  //   List<LatLng>? points,
  // }) {
  //   return Polyline(
  //     polylineId: polylineId ?? this.polylineId,
  //     points: points ?? this.points,
  //   );
  // }
}
