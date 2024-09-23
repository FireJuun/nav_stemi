import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_providers.g.dart';

@Riverpod(keepAlive: true)
List<EdInfo> allEDs(AllEDsRef ref) {
  return locations;
}

@Riverpod(keepAlive: true)
Future<NearbyEds> nearbyEds(NearbyEdsRef ref) {
  return ref.read(routeServiceProvider).getNearbyEDsFromCurrentLocation();
}
