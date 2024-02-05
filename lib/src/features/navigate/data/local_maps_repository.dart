import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_maps_repository.g.dart';

/// Data on the maps will be displayed here.
/// This is stored in memory when [NavScreen] is initialized.
/// It is updated when the user selects a new destination or
/// when the user updates the info on nearby ED distances.
///
class LocalMapsRepository {
  final _store = InMemoryStore<MapsInfo?>(null);

  Stream<MapsInfo?> watchMapsInfo() {
    return _store.stream;
  }

  Future<MapsInfo?> getMapsInfo() async {
    return _store.value;
  }

  Future<void> setMapsInfo(MapsInfo mapsInfo) async {
    _store.value = mapsInfo;
  }

  Future<void> clearMapsInfo() async {
    _store.value = null;
  }
}

@Riverpod(keepAlive: true)
LocalMapsRepository localMapsRepository(LocalMapsRepositoryRef ref) {
  return LocalMapsRepository();
}
