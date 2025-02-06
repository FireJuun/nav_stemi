import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'routes_providers.g.dart';

@riverpod
List<EdInfo> allEDs(Ref ref) {
  return locations;
}

@riverpod
Future<NearbyEds> nearbyEds(Ref ref) {
  return ref.read(routeServiceProvider).getNearbyEDsFromCurrentLocation();
}
