import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'routes_service.g.dart';

class RouteService {
  const RouteService(this.ref);

  final Ref ref;

  GeolocatorRepository get geolocatorRepository =>
      ref.read(geolocatorRepositoryProvider);
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
    final position =
        await ref.read(getLastKnownOrCurrentPositionProvider.future);

    final allEds = ref.read(allEDsProvider);

    final items = <EdInfo, double>{
      for (final ed in allEds)
        ed: geolocatorRepository.getDistanceBetween(
          position,
          ed.location,
        ),
    };
    final sortedItems = nearestTenSortedByDistance(items);

    final origin = position.toLatLng();

    final nearbyEds = await remoteRoutesRepository.getDistanceInfoFromEdList(
      origin: origin,
      edListAndDistances: sortedItems,
    );

    return nearbyEds..sortedByRouteDuration;
  }

  /// Get the available routes for a single emergency department.
  /// Set the default as the active route.
  /// Then set map info, markers, and polylines for this route.
  Future<void> goToEd({
    required NearbyEd activeEd,
    required NearbyEds nearbyEds,
  }) async {
    final position =
        await ref.read(getLastKnownOrCurrentPositionProvider.future);

    final origin = position.toLatLng();

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
        infoWindow: const InfoWindow(title: 'Start'),
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

    const uuid = Uuid();
    final polylinePoints = PolylinePoints();
    final polylines = <PolylineId, Polyline>{};

    for (final route in routes) {
      final polylineString = route.polyline!.encodedPolyline;

      if (polylineString != null) {
        final id = PolylineId(uuid.v4());
        final points = polylinePoints.decodePolyline(polylineString);
        final polyline = Polyline(
          polylineId: id,
          color: Colors.grey,
          width: 8,
          points: points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          onTap: () {
            // TODO(FireJuun): Implement route selection mechanism
            // ref.read(activeRouteProvider).state = route;
          },
        );

        polylines[id] = polyline;
      }
    }

    final mapsInfo = MapsInfo(
      origin: origin,
      destination: destination,
      markers: markers,
      polylines: polylines,
    );

    ref.read(localMapsRepositoryProvider).setMapsInfo(mapsInfo);

    ref
        .read(availableRoutesRepositoryProvider)
        .setAvailableRoutes(availableRoutes);

    // TODO(FireJuun): Implement route selection mechanism and null safety
    final firstRoute = routes.first;
    final activeRoute = ActiveRoute(
      activeRouteId: firstRoute.polyline!.encodedPolyline!,
      activeStepId:
          firstRoute.legs!.first.steps!.first.polyline!.encodedPolyline!,
    );
    ref.read(activeRouteRepositoryProvider).setActiveRoute(activeRoute);
  }
}

@Riverpod(keepAlive: true)
RouteService routeService(RouteServiceRef ref) {
  return RouteService(ref);
}
