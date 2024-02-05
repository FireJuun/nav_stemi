import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maps_providers.g.dart';

@riverpod
LatLng origin(OriginRef ref) {
  final origin =
      ref.watch(remoteMapsRepositoryProvider.select((e) => e.origin));

  // TODO(FireJuun): better handle null values
  return origin ?? const LatLng(0, 0);
}

@riverpod
LatLng destination(DestinationRef ref) {
  final destination =
      ref.watch(remoteMapsRepositoryProvider.select((e) => e.destination));

  // TODO(FireJuun): better handle null values
  return destination ?? const LatLng(0, 0);
}

@riverpod
Set<Marker> markers(MarkersRef ref) {
  final markers =
      ref.watch(remoteMapsRepositoryProvider.select((e) => e.markers));

  return markers.values.toSet();
}

@riverpod
Set<Polyline> polylines(PolylinesRef ref) {
  final polylines =
      ref.watch(remoteMapsRepositoryProvider.select((e) => e.polylines));

  return polylines.values.toSet();
}
