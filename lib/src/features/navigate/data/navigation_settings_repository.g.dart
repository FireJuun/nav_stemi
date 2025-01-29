// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigationSettingsRepositoryHash() =>
    r'8da219eaee50e66238ade24488a58afb847bafee';

/// See also [navigationSettingsRepository].
@ProviderFor(navigationSettingsRepository)
final navigationSettingsRepositoryProvider =
    Provider<NavigationSettingsRepository>.internal(
  navigationSettingsRepository,
  name: r'navigationSettingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationSettingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigationSettingsRepositoryRef
    = ProviderRef<NavigationSettingsRepository>;
String _$navigationSettingsChangesHash() =>
    r'c14d14fcd0cce097fbb689982ffb2ba75fc0a18a';

/// See also [navigationSettingsChanges].
@ProviderFor(navigationSettingsChanges)
final navigationSettingsChangesProvider =
    StreamProvider<NavigationSettings>.internal(
  navigationSettingsChanges,
  name: r'navigationSettingsChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationSettingsChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigationSettingsChangesRef = StreamProviderRef<NavigationSettings>;
String _$audioGuidanceTypeHash() => r'bcc6ef402f259de0be69bf96caf58f9c10ef5d16';

/// See also [audioGuidanceType].
@ProviderFor(audioGuidanceType)
final audioGuidanceTypeProvider =
    AutoDisposeProvider<AudioGuidanceType>.internal(
  audioGuidanceType,
  name: r'audioGuidanceTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioGuidanceTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioGuidanceTypeRef = AutoDisposeProviderRef<AudioGuidanceType>;
String _$shouldSimulateLocationHash() =>
    r'e57d06aabeb6048a6693021c161fc370de28d334';

/// See also [shouldSimulateLocation].
@ProviderFor(shouldSimulateLocation)
final shouldSimulateLocationProvider = AutoDisposeProvider<bool>.internal(
  shouldSimulateLocation,
  name: r'shouldSimulateLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldSimulateLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldSimulateLocationRef = AutoDisposeProviderRef<bool>;
String _$simulationStartingLocationHash() =>
    r'ab24d8cd2e4911b0dea7136435d6aee560ac9954';

/// See also [simulationStartingLocation].
@ProviderFor(simulationStartingLocation)
final simulationStartingLocationProvider =
    AutoDisposeProvider<AppWaypoint?>.internal(
  simulationStartingLocation,
  name: r'simulationStartingLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$simulationStartingLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SimulationStartingLocationRef = AutoDisposeProviderRef<AppWaypoint?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
