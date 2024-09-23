// ignore_for_file: lines_longer_than_80_chars

import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class RemoteRoutesGoogleRepository implements RemoteRoutesRepository {
  final _mapsToRoutesDTO = const MapsToRoutesDTO();

  @override
  Future<NearbyEds> getDistanceInfoFromEdList({
    required maps.LatLng origin,
    required Map<EdInfo, double> edListAndDistances,
  }) async {
    assert(
      edListAndDistances.isNotEmpty,
      'At least one destination is required',
    );
    assert(edListAndDistances.length <= 10, 'Maximum destinations is 10');

    // final requestedTime = DateTime.now();
    final routeMatrixes = await computeRouteMatrix(
      origins: [
        RouteMatrixOrigin(
          waypoint: Waypoint(
            location: Location(
              latLng: _mapsToRoutesDTO.mapsToRoutes(origin),
            ),
          ),
        ),
      ],
      destinations: [
        for (final emergencyDepartment in edListAndDistances.keys)
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng:
                    _mapsToRoutesDTO.mapsToRoutes(emergencyDepartment.location),
              ),
            ),
          ),
      ],
      xGoogFieldMask:
          'originIndex,destinationIndex,status,condition,distanceMeters,duration',
      apiKey: Env.routesApi,
    );

    final items = <maps.LatLng, NearbyEd>{};

    assert(routeMatrixes.isNotEmpty, 'No routes found');
    assert(
      routeMatrixes.length == edListAndDistances.length,
      'Routes length mismatch',
    );

    for (var i = 0; i < routeMatrixes.length; i++) {
      final routeEntry =
          routeMatrixes.firstWhere((e) => e.destinationIndex == i);
      assert(i == routeEntry.destinationIndex, 'Index mismatch');
      final destination = edListAndDistances.entries.elementAt(i);
      final edInfo = destination.key;
      final distanceBetween = destination.value;

      items[edInfo.location] = NearbyEd(
        distanceBetween: distanceBetween,
        routeDistance: routeEntry.distanceMeters,
        routeDuration: routeEntry.duration,
        edInfo: edInfo,
      );
    }

    return NearbyEds(items: items);
  }

  @override
  Future<AvailableRoutes> getAvailableRoutesForSingleED({
    required maps.LatLng origin,
    required maps.LatLng destination,
    required EdInfo destinationInfo,
  }) async {
    final requestedTime = DateTime.now();

    final routes = await computeRoute(
      origin: Waypoint(
        location: Location(
          latLng: _mapsToRoutesDTO.mapsToRoutes(origin),
        ),
      ),
      destination: Waypoint(
        location: Location(
          latLng: _mapsToRoutesDTO.mapsToRoutes(destination),
        ),
      ),
      xGoogFieldMask:
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs.*',
      apiKey: Env.routesApi,
    );

    return AvailableRoutes(
      origin: origin,
      destination: destination,
      destinationInfo: destinationInfo,
      requestedDateTime: requestedTime,
      routes: routes.routes,
    );
  }
}
