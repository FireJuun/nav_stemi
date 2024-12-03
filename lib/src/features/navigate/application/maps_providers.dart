import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maps_providers.g.dart';

@riverpod
Stream<MapsInfo?> mapsInfo(MapsInfoRef ref) {
  return ref.watch(localMapsRepositoryProvider).watchMapsInfo();
}

@riverpod
AppWaypoint? origin(OriginRef ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.origin;
}

@riverpod
AppWaypoint? destination(DestinationRef ref) {
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
