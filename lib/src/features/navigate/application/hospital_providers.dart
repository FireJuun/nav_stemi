import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hospital_providers.g.dart';

// TODO(FireJuun): swap to Firebase list of locations
@riverpod
List<Hospital> allHospitals(Ref ref) {
  return locations;
}

@riverpod
Future<NearbyHospitals> nearbyHospitals(Ref ref) {
  return ref.read(routeServiceProvider).getNearbyHospitalsFromCurrentLocation();
}
