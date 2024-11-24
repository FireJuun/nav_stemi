import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/src/features/navigate/data/google_navigation_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_navigation_providers.g.dart';

@riverpod
Stream<Destinations?> destinations(DestinationsRef ref) {
  return ref.watch(googleNavigationRepositoryProvider).watchDestinations();
}

@riverpod
Stream<NavInfo?> navInfo(NavInfoRef ref) {
  return ref.watch(googleNavigationRepositoryProvider).watchNavInfo();
}
