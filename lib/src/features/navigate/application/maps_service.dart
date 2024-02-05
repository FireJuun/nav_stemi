import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maps_service.g.dart';

class MapsService {
  const MapsService(this.ref);

  final Ref ref;

  LocalMapsRepository get localMapsRepository =>
      ref.read(localMapsRepositoryProvider);
  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);

  /// Check location permission and return the current location as [LatLng].
  Future<LatLng> currentLocation() async {
    final position =
        await ref.read(geolocatorRepositoryProvider).determinePosition();
    return LatLng(position.latitude, position.longitude);
  }
}

@Riverpod(keepAlive: true)
MapsService mapsService(MapsServiceRef ref) {
  return MapsService(ref);
}
