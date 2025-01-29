import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_providers.g.dart';

@Riverpod(keepAlive: true)
List<EdInfo> allEDs(Ref ref) {
  return locations;
}

@Riverpod(keepAlive: true)
Future<NearbyEds> nearbyEds(Ref ref) {
  return ref.read(routeServiceProvider).getNearbyEDsFromCurrentLocation();
}
