import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_providers.g.dart';

@Riverpod(keepAlive: true)
List<EdInfo> allEDs(AllEDsRef ref) {
  return locations;
}

@riverpod
Future<NearbyEds> nearbyEds(NearbyEdsRef ref) async {
  final nearbyEds =
      await ref.read(routeServiceProvider).getNearbyEDsFromCurrentLocation();

  return nearbyEds..sortedByRouteDuration;
}
