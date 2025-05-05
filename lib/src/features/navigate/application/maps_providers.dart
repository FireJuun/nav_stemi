import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maps_providers.g.dart';

@riverpod
Stream<MapsInfo?> mapsInfo(Ref ref) {
  return ref.watch(localMapsRepositoryProvider).watchMapsInfo();
}

@riverpod
AppWaypoint? origin(Ref ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.origin;
}

@riverpod
AppWaypoint? destination(Ref ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.destination;
}

@riverpod
Set<Marker> markers(Ref ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.markers.values.toSet() ?? <Marker>{};
}

@riverpod
Set<Polyline> polylines(Ref ref) {
  final mapsInfoStream = ref.watch(mapsInfoProvider).value;

  return mapsInfoStream?.polylines.values.toSet() ?? <Polyline>{};
}
