import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ActiveRouteRepository {
  final _activeRoute = InMemoryStore<ComputeRouteResult?>(null);
  final _routeMatrix = InMemoryStore<List<RouteMatrixEntry>?>(null);

  Future<ComputeRouteResult> getRoute() async => computeRoute(
        origin: const Waypoint(
          location: Location(
            latLng: locationRandolphEms,
          ),
        ),
        destination: Waypoint(
          location: Location(
            latLng: Locations.atriumStanly.loc,
          ),
        ),
        xGoogFieldMask: 'routes.distanceMeters,routes.routeLabels',
        apiKey: Env.routesApi,
      );

  Future<List<RouteMatrixEntry>> getRouteMatrix() async => computeRouteMatrix(
        origins: [
          const RouteMatrixOrigin(
            waypoint: Waypoint(
              location: Location(
                latLng: locationRandolphEms,
              ),
            ),
          ),
        ],
        destinations: [
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng: Locations.atriumStanly.loc,
              ),
            ),
          ),
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng: Locations.atriumWakeHighPoint.loc,
              ),
            ),
          ),
          RouteMatrixDestination(
            waypoint: Waypoint(
              location: Location(
                latLng: Locations.randolph.loc,
              ),
            ),
          ),
        ],
        xGoogFieldMask: 'distanceMeters',
        apiKey: Env.routesApi,
      );
}
