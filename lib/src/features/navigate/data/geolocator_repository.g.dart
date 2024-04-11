// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocator_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geolocatorRepositoryHash() =>
    r'2046929b53322692ed41701a5e24efabbf2839d5';

/// See also [geolocatorRepository].
@ProviderFor(geolocatorRepository)
final geolocatorRepositoryProvider = Provider<GeolocatorRepository>.internal(
  geolocatorRepository,
  name: r'geolocatorRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geolocatorRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GeolocatorRepositoryRef = ProviderRef<GeolocatorRepository>;
String _$watchPositionHash() => r'1aae2bd41545cc89a0a93522c7bc8b891e6428d5';

/// See also [watchPosition].
@ProviderFor(watchPosition)
final watchPositionProvider = AutoDisposeStreamProvider<Position?>.internal(
  watchPosition,
  name: r'watchPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$watchPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WatchPositionRef = AutoDisposeStreamProviderRef<Position?>;
String _$getCurrentPositionHash() =>
    r'1e41396a73137122b67c8e9a30ab504650ac7422';

/// See also [getCurrentPosition].
@ProviderFor(getCurrentPosition)
final getCurrentPositionProvider = AutoDisposeFutureProvider<Position>.internal(
  getCurrentPosition,
  name: r'getCurrentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCurrentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetCurrentPositionRef = AutoDisposeFutureProviderRef<Position>;
String _$getLastKnownPositionHash() =>
    r'31a800417ffd195a86db23e09a6c57c984b4f19e';

/// See also [getLastKnownPosition].
@ProviderFor(getLastKnownPosition)
final getLastKnownPositionProvider =
    AutoDisposeFutureProvider<Position?>.internal(
  getLastKnownPosition,
  name: r'getLastKnownPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getLastKnownPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetLastKnownPositionRef = AutoDisposeFutureProviderRef<Position?>;
String _$getLastKnownOrCurrentPositionHash() =>
    r'e4883cfef578279c0b34a9d96b77babeb39acbda';

/// See also [getLastKnownOrCurrentPosition].
@ProviderFor(getLastKnownOrCurrentPosition)
final getLastKnownOrCurrentPositionProvider =
    AutoDisposeFutureProvider<Position>.internal(
  getLastKnownOrCurrentPosition,
  name: r'getLastKnownOrCurrentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getLastKnownOrCurrentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetLastKnownOrCurrentPositionRef
    = AutoDisposeFutureProviderRef<Position>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
