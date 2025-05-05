import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class RemoteRoutesGoogleRepository implements RemoteRoutesRepository {
  @override
  Future<NearbyHospitals> getDistanceInfoFromHospitalList({
    required AppWaypoint origin,
    required Map<Hospital, double> hospitalListAndDistances,
  }) async {
    assert(
      hospitalListAndDistances.isNotEmpty,
      'At least one destination is required',
    );
    assert(hospitalListAndDistances.length <= 10, 'Maximum destinations is 10');

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
        for (final hospital in hospitalListAndDistances.keys)
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng: hospital.location().toGoogleRoutes(),
              ),
            ),
          ),
      ],
      xGoogFieldMask:
          'originIndex,destinationIndex,status,condition,distanceMeters,duration',
      apiKey: Env.routesApi,
    );

    final items = <AppWaypoint, NearbyHospital>{};

    assert(routeMatrixes.isNotEmpty, 'No routes found');
    assert(
      routeMatrixes.length == hospitalListAndDistances.length,
      'Routes length mismatch',
    );

    for (var i = 0; i < routeMatrixes.length; i++) {
      final routeEntry =
          routeMatrixes.firstWhere((e) => e.destinationIndex == i);
      assert(i == routeEntry.destinationIndex, 'Index mismatch');
      final destination = hospitalListAndDistances.entries.elementAt(i);
      final hospitalInfo = destination.key;
      final distanceBetween = destination.value;

      items[hospitalInfo.location()] = NearbyHospital(
        distanceBetween: distanceBetween,
        routeDistance: routeEntry.distanceMeters,
        routeDuration: routeEntry.duration,
        hospitalInfo: hospitalInfo,
      );
    }

    return NearbyHospitals(items: items);
  }

  @override
  Future<AvailableRoutes> getAvailableRoutesForSingleHospital({
    required AppWaypoint origin,
    required AppWaypoint destination,
    required Hospital destinationInfo,
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
