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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeolocatorRepositoryRef = ProviderRef<GeolocatorRepository>;
String _$watchPositionHash() => r'117a2afb9d7bd6dc341e5e7067444ea68dc7cfbf';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLastKnownPositionRef = AutoDisposeFutureProviderRef<Position?>;
String _$getLastKnownOrCurrentPositionHash() =>
    r'83eed17d204262146489b74088f8ec238e808c6e';

/// Get the last known position of the device, if available.
/// Otherwise, get the current position of the device, which
/// forces the device to get the current location and may take
/// longer to return a result.
///
/// Copied from [getLastKnownOrCurrentPosition].
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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLastKnownOrCurrentPositionRef
    = AutoDisposeFutureProviderRef<Position>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
