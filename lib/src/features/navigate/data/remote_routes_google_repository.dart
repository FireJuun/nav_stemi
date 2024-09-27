import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class RemoteRoutesGoogleRepository implements RemoteRoutesRepository {
  @override
  Future<NearbyEds> getDistanceInfoFromEdList({
    required AppWaypoint origin,
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
              latLng: origin.toGoogleRoutes(),
            ),
          ),
        ),
      ],
      destinations: [
        for (final emergencyDepartment in edListAndDistances.keys)
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng: emergencyDepartment.location.toGoogleRoutes(),
              ),
            ),
          ),
      ],
      xGoogFieldMask:
          'originIndex,destinationIndex,status,condition,distanceMeters,duration',
      apiKey: Env.routesApi,
    );

    final items = <AppWaypoint, NearbyEd>{};

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
    required AppWaypoint origin,
    required AppWaypoint destination,
    required EdInfo destinationInfo,
  }) async {
    final requestedTime = DateTime.now();

    final routes = await computeRoute(
      origin: Waypoint(
        location: Location(
          latLng: origin.toGoogleRoutes(),
        ),
      ),
      destination: Waypoint(
        location: Location(
          latLng: destination.toGoogleRoutes(),
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
