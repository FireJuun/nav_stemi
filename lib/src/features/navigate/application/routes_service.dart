import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_service.g.dart';

class RouteService {
  const RouteService(this.ref);

  final Ref ref;

  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);
  LocalMapsRepository get localMapsRepository =>
      ref.read(localMapsRepositoryProvider);
  RemoteRoutesRepository get remoteRoutesRepository =>
      ref.read(remoteRoutesRepositoryProvider);

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

  /// First check to see the current location of the user,
  /// then get the nearby emergency departments.
  Future<NearbyEds> getNearbyEDsFromCurrentLocation() async {
    final currentLocation = await geolocatorRepository.determinePosition();
    final allEds = ref.read(allEDsProvider);

    final items = <EdInfo, double>{
      for (final ed in allEds)
        ed: geolocatorRepository.getDistanceBetween(
          currentLocation,
          ed.location,
        ),
    };
    final sortedItems = nearestTenSortedByDistance(items);

    return remoteRoutesRepository.getDistanceInfoFromEdList(
      origin: LatLng(currentLocation.latitude, currentLocation.longitude),
      edListAndDistances: sortedItems,
    );
  }

  /// Get the available routes for a single emergency department.
  /// Set the default as the active route.
  /// Then set map info, markers, and polylines for this route.
  Future<void> goToEd({
    required NearbyEd activeEd,
    required NearbyEds nearbyEds,
  }) async {
    final currentLocation = await geolocatorRepository.determinePosition();
    final origin = LatLng(currentLocation.latitude, currentLocation.longitude);
    final destination = activeEd.edInfo.location;

    final availableRoutes =
        await remoteRoutesRepository.getAvailableRoutesForSingleED(
      origin: origin,
      destination: destination,
    );

    final markers = {
      const MarkerId('origin'): Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
      const MarkerId('destination'): Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(title: activeEd.edInfo.shortName),
      ),
    };

    final routes = availableRoutes.routes;

    if (routes == null || routes.isEmpty) {
      throw Exception('No routes available');
    }

    // TODO(FireJuun): better null safety / error handling
    final polylines = {
      for (final route in routes)
        PolylineId(route.polyline!.encodedPolyline!): Polyline(
          polylineId: PolylineId(route.polyline!.encodedPolyline!),
        ),
    };

    final mapsInfo = MapsInfo(
      origin: origin,
      destination: destination,
      markers: markers,
      polylines: polylines,
    );

    ref.read(localMapsRepositoryProvider).setMapsInfo(mapsInfo);
  }
}

@Riverpod(keepAlive: true)
RouteService routeService(RouteServiceRef ref) {
  return RouteService(ref);
}
