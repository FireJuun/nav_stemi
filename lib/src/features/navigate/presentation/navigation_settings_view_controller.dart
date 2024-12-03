import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_settings_view_controller.g.dart';

@riverpod
class NavigationSettingsViewController
    extends _$NavigationSettingsViewController with NotifierMounted {
  @override
  FutureOr<void> build() {
    // nothing to do
    state = const AsyncData(null);
    ref.onDispose(setUnmounted);
  }

  NavigationSettingsRepository get _navigationSettingsRepository =>
      ref.read(navigationSettingsRepositoryProvider);

  void setShowNorthUp({required bool value}) =>
      _navigationSettingsRepository.setShowNorthUp(value: value);

  void setAudioGuidanceType({required AudioGuidanceType value}) =>
      _navigationSettingsRepository.setAudioGuidanceType(value: value);

  void setShouldSimulateLocation({required bool value}) =>
      _navigationSettingsRepository.setShouldSimulateLocation(value: value);

  void setSimulationSpeedMultiplier({required double value}) =>
      _navigationSettingsRepository.setSimulationSpeedMultiplier(value: value);

  void setSimulationStartingLocation({required AppWaypoint? value}) =>
      _navigationSettingsRepository.setSimulationStartingLocation(value: value);
}
