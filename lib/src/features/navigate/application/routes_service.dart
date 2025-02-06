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
  NavigationSettingsRepository get navigationSettingsRepository =>
      ref.read(navigationSettingsRepositoryProvider);

  /// First check to see the current location of the user,
  /// then get the nearby emergency departments.
  Future<NearbyEds> getNearbyEDsFromCurrentLocation() async {
    final navigationSettings = navigationSettingsRepository.navigationSettings;
    final shouldSimulateLocation = navigationSettings.shouldSimulateLocation;
    final simulationStartingLocation =
        navigationSettings.simulationStartingLocation;

    late final AppWaypoint origin;

    /// If we are simulating location, then use the simulationStartingLocation,
    /// which cannot be set to null.
    ///
    /// Otherwise use the current location of the user.
    ///
    if (shouldSimulateLocation) {
      // TODO(FireJuun): reimplement ability for starting location to be null
      // assert(
      //   simulationStartingLocation != null,
      //   'If simulating a location, then simulationStartingLocation must be set',
      // );

      origin = navigationSettings.simulationStartingLocation;
    } else {
      final lastKnownPosition =
          await ref.read(getLastKnownOrCurrentPositionProvider.future);
      origin = lastKnownPosition.toAppWaypoint();
    }

    final allEds = ref.read(allEDsProvider);

    final items = <EdInfo, double>{
      for (final ed in allEds)
        ed: geolocatorRepository.getDistanceBetween(
          origin,
          ed.location,
        ),
    };
    final sortedItems = nearestTenSortedByDistance(items);

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

@riverpod
RouteService routeService(Ref ref) {
  return RouteService(ref);
}
