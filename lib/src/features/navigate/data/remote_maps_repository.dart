import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_maps_repository.g.dart';

// TODO(FireJuun): extract into DTO
const _util = GoogleMapsToRoutesUtil();

class RemoteMapsRepository {
  final origin = _util.routesToMaps(locationRandolphEms);
  final destination = _util.routesToMaps(Locations.atriumWakeHighPoint.loc);

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

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
