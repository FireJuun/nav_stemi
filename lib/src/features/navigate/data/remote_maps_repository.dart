import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_maps_repository.g.dart';

class RemoteMapsRepository {
  LatLng? origin;
  LatLng? destination;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

  void setOrigin(LatLng origin) {
    this.origin = origin;
  }
}

@Riverpod(keepAlive: true)
RemoteMapsRepository remoteMapsRepository(RemoteMapsRepositoryRef ref) {
  return RemoteMapsRepository();
}
