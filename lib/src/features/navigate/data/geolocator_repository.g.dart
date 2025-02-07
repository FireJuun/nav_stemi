// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocator_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$geolocatorRepositoryHash() =>
    r'793fac9e475417e458323f7cc05d9947f071fec4';

/// See also [geolocatorRepository].
@ProviderFor(geolocatorRepository)
final geolocatorRepositoryProvider =
    AutoDisposeProvider<GeolocatorRepository>.internal(
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
typedef GeolocatorRepositoryRef = AutoDisposeProviderRef<GeolocatorRepository>;
String _$watchPositionHash() => r'3cd3c7d726645dd121b7fe7d6ba25abce58bfa68';

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
    r'94478b6f8440b40310a2f7981ba834a144c0315b';

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
    r'8cf1a661af1ccfafd923a03fe38197157b80f90e';

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
    r'80ae7e1499c75f20cc7932bef91205b429bf310a';

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
