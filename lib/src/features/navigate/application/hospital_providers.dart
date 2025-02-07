import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hospital_providers.g.dart';

@riverpod
Future<List<Hospital>> allHospitals(Ref ref) async {
  return ref.read(hospitalsRepositoryProvider).fetchHospitals();
}

@riverpod
Future<NearbyHospitals> nearbyHospitals(Ref ref) {
  return ref.read(routeServiceProvider).getNearbyHospitalsFromCurrentLocation();
}
