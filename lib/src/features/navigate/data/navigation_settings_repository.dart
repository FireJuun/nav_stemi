import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void setShowNorthUp({required bool value}) {
    navigationSettings = navigationSettings.copyWith(showNorthUp: value);
  }

  void setAudioGuidanceType({required AudioGuidanceType value}) {
    navigationSettings = navigationSettings.copyWith(audioGuidanceType: value);
  }

  void setShouldSimulateLocation({required bool value}) {
    navigationSettings =
        navigationSettings.copyWith(shouldSimulateLocation: value);
  }

  void setSimulationSpeedMultiplier({required double value}) {
    navigationSettings =
        navigationSettings.copyWith(simulationSpeedMultiplier: value);
  }

  void setSimulationStartingLocation({required AppWaypoint value}) {
    navigationSettings =
        navigationSettings.copyWith(simulationStartingLocation: () => value);
  }

  Stream<NavigationSettings> navigationSettingsChanges() => _store.stream;
}

@Riverpod(keepAlive: true)
NavigationSettingsRepository navigationSettingsRepository(Ref ref) {
  ///  set this in the app bootstrap section
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Stream<NavigationSettings> navigationSettingsChanges(Ref ref) {
  return ref
      .watch(navigationSettingsRepositoryProvider)
      .navigationSettingsChanges();
}

@riverpod
AudioGuidanceType audioGuidanceType(Ref ref) {
  return ref.watch(
        navigationSettingsChangesProvider
            .select((settings) => settings.value?.audioGuidanceType),
      ) ??
      AudioGuidanceType.alertsAndGuidance;
}

@riverpod
bool shouldSimulateLocation(Ref ref) {
  return ref.watch(
    navigationSettingsChangesProvider
        .select((settings) => settings.value?.shouldSimulateLocation ?? false),
  );
}

@riverpod
AppWaypoint? simulationStartingLocation(Ref ref) {
  return ref.watch(
    navigationSettingsChangesProvider
        .select((settings) => settings.value?.simulationStartingLocation),
  );
}
