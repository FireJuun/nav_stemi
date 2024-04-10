import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

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

@riverpod
Future<LatLng> initialLocation(InitialLocationRef ref) async {
  final position =
      await ref.read(geolocatorRepositoryProvider).determinePosition();
  return LatLng(position.latitude, position.longitude);
}

@riverpod
Stream<LatLng?> currentLocation(CurrentLocationRef ref) {
  final geolocator = ref.read(geolocatorRepositoryProvider);

  /// include last known position as the first value
  /// to avoid waiting for the first position update
  final lastKnownPositionStream = Stream.fromFuture(
    geolocator.lastKnownPosition(),
  );

  /// watch for changes to the current position
  final positionStream = geolocator.watchPosition();

  /// emit both the last known position and the current position
  return Rx.merge([lastKnownPositionStream, positionStream]).map(
    (event) => event != null ? LatLng(event.latitude, event.longitude) : null,
  );
}
