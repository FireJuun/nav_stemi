import 'package:nav_stemi/nav_stemi.dart';
import 'package:nav_stemi/src/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'available_routes_repository.g.dart';

/// Data on the maps will be displayed here.
/// This is stored in memory when [NavScreen] is initialized.
/// It is updated when the user selects a new destination or
/// when the user updates the info on nearby ED distances.
///
class AvailableRoutesRepository {
  final _store = InMemoryStore<AvailableRoutes?>(null);

  Stream<AvailableRoutes?> watchAvailableRoutes() {
    return _store.stream;
  }

  AvailableRoutes? getAvailableRoutes() {
    return _store.value;
  }

  void setAvailableRoutes(AvailableRoutes availableRoutes) {
    _store.value = availableRoutes;
  }

  void clearAvailableRoutes() {
    _store.value = null;
  }
}

@Riverpod(keepAlive: true)
AvailableRoutesRepository availableRoutesRepository(
  AvailableRoutesRepositoryRef ref,
) {
  return AvailableRoutesRepository();
}

@riverpod
Stream<AvailableRoutes?> availableRoutes(AvailableRoutesRef ref) {
  final availableRoutesRepository =
      ref.watch(availableRoutesRepositoryProvider);
  return availableRoutesRepository.watchAvailableRoutes();
}
