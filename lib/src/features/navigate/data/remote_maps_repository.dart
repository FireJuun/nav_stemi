import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_maps_repository.g.dart';

// TODO(FireJuun): extract into DTO
const _util = GoogleMapsToRoutesUtil();

class RemoteMapsRepository {
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  final origin = _util.routesToMaps(locationRandolphEms);
  final destination = _util.routesToMaps(Locations.atriumWakeHighPoint.loc);

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    final markerId = MarkerId(id);
    final marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }
}

@Riverpod(keepAlive: true)
RemoteMapsRepository remoteMapsRepository(RemoteMapsRepositoryRef ref) {
  return RemoteMapsRepository();
}

@riverpod
LatLng origin(OriginRef ref) {
  return ref.watch(remoteMapsRepositoryProvider.select((e) => e.origin));
}

@riverpod
LatLng destination(DestinationRef ref) {
  return ref.watch(remoteMapsRepositoryProvider.select((e) => e.destination));
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
