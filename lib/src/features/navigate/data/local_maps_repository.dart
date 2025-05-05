import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_maps_repository.g.dart';

/// Data on the maps will be displayed here.
/// This is stored in memory when [NavScreenGoogle] is initialized.
/// It is updated when the user selects a new destination or
/// when the user updates the info on nearby ED distances.
///
class LocalMapsRepository {
  final _store = InMemoryStore<MapsInfo?>(null);

  Stream<MapsInfo?> watchMapsInfo() {
    return _store.stream;
  }

  MapsInfo? getMapsInfo() {
    return _store.value;
  }

  void setMapsInfo(MapsInfo mapsInfo) {
    _store.value = mapsInfo;
  }

  void clearMapsInfo() {
    _store.value = null;
  }
}

@riverpod
LocalMapsRepository localMapsRepository(Ref ref) {
  return LocalMapsRepository();
}
