import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class RemoteRoutesRepository {
  Future<void> getData() async {
    final result = await computeRoute(
      origin: const Waypoint(location: Location(latLng: locationRandolphEms)),
      destination:
          const Waypoint(location: Location(latLng: locationRandolphEms)),
      xGoogFieldMask:
          'routes.duration,routes.distanceMeters, routes.polyline.encodedPolyline',
      apiKey: Env.routesApi,
    );
  }
}
