import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_routes_flutter/google_routes_flutter.dart' as routes;

/// Helper function to swap between the Google Maps Flutter package and
/// the Google Routes Flutter package, which both have LatLng() defined.
///
class GoogleMapsToRoutesUtil {
  const GoogleMapsToRoutesUtil();

  maps.LatLng routesToMaps(routes.LatLng latLng) {
    assert(latLng.latitude != null, 'Error: latitude must not be null');
    assert(latLng.longitude != null, 'Error: longitude must not be null');

    return maps.LatLng(latLng.latitude!, latLng.longitude!);
  }

  routes.LatLng mapsToRoutes(maps.LatLng latLng) =>
      routes.LatLng(latitude: latLng.latitude, longitude: latLng.longitude);
}
