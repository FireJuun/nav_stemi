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
          ed.location.toGoogleMaps(),
        ),
    };
    final sortedItems = nearestTenSortedByDistance(items);

    final origin = position.toAppWaypoint();

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

    final origin = position.toAppWaypoint();
    final destination = activeEd.edInfo.location;

    /// Get available routes, and set the default as the active route.
    final availableRoutes = await _setupAvailableRoutes(
      origin,
      destination,
      activeEd.edInfo,
    );

    /// Set map info, markers, and polylines for this route.
    final markers = await _setupMarkers(
      activeEd: activeEd,
      nearbyEds: nearbyEds,
      destination: destination,
    );

    final polylines = _setupPolylines(availableRoutes);

    final mapsInfo = MapsInfo(
      origin: origin.toGoogleMaps(),
      destination: destination.toGoogleMaps(),
      markers: markers,
      polylines: polylines,
    );

    ref.read(localMapsRepositoryProvider).setMapsInfo(mapsInfo);
  }

  Future<AvailableRoutes> _setupAvailableRoutes(
    AppWaypoint origin,
    AppWaypoint destination,
    EdInfo destinationInfo,
  ) async {
    final availableRoutes =
        await remoteRoutesRepository.getAvailableRoutesForSingleED(
      origin: origin,
      destination: destination,
      destinationInfo: destinationInfo,
    );
    ref
        .read(availableRoutesRepositoryProvider)
        .setAvailableRoutes(availableRoutes);

    await _setupActiveRoute(availableRoutes);

    return availableRoutes;
  }

  Future<void> _setupActiveRoute(AvailableRoutes availableRoutes) async {
    final routes = availableRoutes.routes;
    assert(routes != null, 'routes should not be null');

    final firstRoute = routes!.first;
    final activeStepId =
        firstRoute.legs?.first.steps?.first.polyline?.encodedPolyline;

    assert(activeStepId != null, 'Current route needs to have valid steps');

    final activeRoute = ActiveRoute(
      route: firstRoute,
      activeStepId: activeStepId!,
    );

    ref.read(activeRouteRepositoryProvider).setActiveRoute(activeRoute);
  }

  Future<Map<MarkerId, Marker>> _setupMarkers({
    required NearbyEd activeEd,
    required NearbyEds nearbyEds,
    required AppWaypoint destination,
  }) async {
    final markers = {
      const MarkerId('destination'): Marker(
        markerId: const MarkerId('destination'),
        position: destination.toGoogleMaps(),
        infoWindow: InfoWindow(title: activeEd.edInfo.shortName),
        onTap: () => ref
            .read(goRouterProvider)
            .goNamed(AppRoute.navInfo.name, extra: activeEd.edInfo),
      ),
    };

    final pciIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    final edIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

    /// add each ED as a marker on the map
    for (final ed in nearbyEds.items.values) {
      if (ed.edInfo.location != activeEd.edInfo.location) {
        markers[MarkerId(ed.edInfo.shortName)] = Marker(
          markerId: MarkerId(ed.edInfo.shortName),
          position: ed.edInfo.location.toGoogleMaps(),
          icon: ed.edInfo.isPCI ? pciIcon : edIcon,
          infoWindow: InfoWindow(title: ed.edInfo.shortName),
          onTap: () => ref
              .read(goRouterProvider)
              .goNamed(AppRoute.navInfo.name, extra: ed.edInfo),
        );
      }
    }

    return markers;
  }

  Map<PolylineId, Polyline> _setupPolylines(
    AvailableRoutes availableRoutes,
  ) {
    /// add each route as a polyline on the map
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

    return polylines;
  }
}

@Riverpod(keepAlive: true)
RouteService routeService(RouteServiceRef ref) {
  return RouteService(ref);
}
