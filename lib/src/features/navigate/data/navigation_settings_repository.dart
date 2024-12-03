import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_settings_repository.g.dart';

class NavigationSettingsRepository {
  NavigationSettingsRepository(this._lastNavigationSettings);
  final NavigationSettings _lastNavigationSettings;

  late final _store =
      InMemoryStore<NavigationSettings>(_lastNavigationSettings);
  NavigationSettings get navigationSettings => _store.value;
  set navigationSettings(NavigationSettings value) => _store.value = value;

  Stream<NavigationSettings> navigationSettingsChanges() => _store.stream;
}

@Riverpod(keepAlive: true)
NavigationSettingsRepository navigationSettingsRepository(
  NavigationSettingsRepositoryRef ref,
) {
  ///  set this in the app bootstrap section
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Stream<NavigationSettings> navigationSettingsChanges(
  NavigationSettingsChangesRef ref,
) {
  return ref
      .watch(navigationSettingsRepositoryProvider)
      .navigationSettingsChanges();
}
