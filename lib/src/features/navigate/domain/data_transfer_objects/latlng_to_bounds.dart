import 'dart:math';

import 'package:google_navigation_flutter/google_navigation_flutter.dart';

/// Helper class to determine the bounds of a list of [LatLng]
/// objects.
///
/// DTO: Data Transfer Object
///
/// spec: https://stackoverflow.com/questions/66545517/flutter-googlemap-i-need-to-find-latlngbounds-from-a-list-of-latlnglatitude
///
class LatLngBoundsDTO {
  LatLngBounds listToBounds(List<LatLng> list) {
    assert(list.isNotEmpty, 'list must not be empty');
    final firstLatLng = list.first;
    var s = firstLatLng.latitude;
    var n = firstLatLng.latitude;
    var w = firstLatLng.longitude;
    var e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      final latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(latitude: s, longitude: w),
      northeast: LatLng(latitude: n, longitude: e),
    );
  }
}
