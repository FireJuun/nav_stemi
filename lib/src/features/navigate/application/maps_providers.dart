import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maps_providers.g.dart';

@riverpod
Stream<MapsInfo?> mapsInfo(MapsInfoRef ref) {
  return ref.watch(localMapsRepositoryProvider).watchMapsInfo();
}

@riverpod
LatLng? origin(OriginRef ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.origin;
}

@riverpod
LatLng? destination(DestinationRef ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.destination;
}

@riverpod
Set<Marker> markers(MarkersRef ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.markers.values.toSet() ?? <Marker>{};
}

@riverpod
Set<Polyline> polylines(PolylinesRef ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.polylines.values.toSet() ?? <Polyline>{};
}
