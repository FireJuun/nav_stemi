import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_service.g.dart';

class RouteService {
  const RouteService(this.ref);

  final Ref ref;

  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);
  GoogleNavigationService get googleNavigationService =>
      ref.read(googleNavigationServiceProvider);
  RemoteRoutesRepository get remoteRoutesRepository =>
      ref.read(remoteRoutesRepositoryProvider);

  /// First check to see the current location of the user,
  /// then get the nearby emergency departments.
  Future<NearbyEds> getNearbyEDsFromCurrentLocation() async {
    final position =
        await ref.read(getLastKnownOrCurrentPositionProvider.future);

    final allEds = ref.read(allEDsProvider);

    final items = <EdInfo, double>{
      for (final ed in allEds)
        ed: geolocatorRepository.getDistanceBetween(
          position,
          ed.location.toGoogleMaps(),
        ),
    };
    final sortedItems = nearestTenSortedByDistance(items);

    final origin = position.toAppWaypoint();

    final nearbyEds = await remoteRoutesRepository.getDistanceInfoFromEdList(
      origin: origin,
      edListAndDistances: sortedItems,
    );

    final nearbyEdsByDuration = nearbyEds.sortedByRouteDuration;

    return nearbyEdsByDuration;
  }

  @visibleForTesting
  Map<EdInfo, double> nearestTenSortedByDistance(Map<EdInfo, double> items) {
    /// spec: https://stackoverflow.com/a/72172892
    final sorted = Map.fromEntries(
      items.entries.toList()..sort((a, b) => a.value.compareTo(b.value)),
    );

    final nearestTen = <EdInfo, double>{};
    for (final entry in sorted.entries.take(10)) {
      nearestTen[entry.key] = entry.value;
    }

    return nearestTen;
  }
}

@Riverpod(keepAlive: true)
RouteService routeService(RouteServiceRef ref) {
  return RouteService(ref);
}
