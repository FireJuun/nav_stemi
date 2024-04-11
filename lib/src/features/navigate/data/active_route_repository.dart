import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_route_repository.g.dart';

/// Data on the maps will be displayed here.
/// This is stored in memory when [NavScreen] is initialized.
/// It is updated when the user selects a new destination or
/// when the user updates the info on nearby ED distances.
///
class ActiveRouteRepository {
  final _store = InMemoryStore<ActiveRoute?>(null);

  Stream<ActiveRoute?> watchActiveRoute() {
    return _store.stream;
  }

  // ActiveRoute? getActiveRoute() {
  //   return _store.value;
  // }

  void setActiveRoute(ActiveRoute activeRoute) {
    _store.value = activeRoute;
  }

  void clearActiveRoute() {
    _store.value = null;
  }
}

@Riverpod(keepAlive: true)
ActiveRouteRepository activeRouteRepository(ActiveRouteRepositoryRef ref) {
  return ref.watch(activeRouteRepositoryProvider);
}

@riverpod
Stream<ActiveRoute?> activeRoute(ActiveRouteRef ref) {
  final activeRouteRepository = ref.watch(activeRouteRepositoryProvider);
  return activeRouteRepository.watchActiveRoute();
}
