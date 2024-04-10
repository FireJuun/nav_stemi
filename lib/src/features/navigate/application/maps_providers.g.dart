// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maps_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mapsInfoHash() => r'360e70e20239377b665fdcdc1e40ba20b80bcfb1';

/// See also [mapsInfo].
@ProviderFor(mapsInfo)
final mapsInfoProvider = AutoDisposeStreamProvider<MapsInfo?>.internal(
  mapsInfo,
  name: r'mapsInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mapsInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MapsInfoRef = AutoDisposeStreamProviderRef<MapsInfo?>;
String _$originHash() => r'e6d8ace09d0b893ca61f86c14f8fd7ef818789c5';

/// See also [origin].
@ProviderFor(origin)
final originProvider = AutoDisposeProvider<LatLng?>.internal(
  origin,
  name: r'originProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$originHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OriginRef = AutoDisposeProviderRef<LatLng?>;
String _$destinationHash() => r'0c67b2656af4602c70e787b57a095d1e96c92c66';

/// See also [destination].
@ProviderFor(destination)
final destinationProvider = AutoDisposeProvider<LatLng?>.internal(
  destination,
  name: r'destinationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$destinationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DestinationRef = AutoDisposeProviderRef<LatLng?>;
String _$markersHash() => r'6b5ab3cc4e275e6b734e99e4fe4a784d4b438362';

/// See also [markers].
@ProviderFor(markers)
final markersProvider = AutoDisposeProvider<Set<Marker>>.internal(
  markers,
  name: r'markersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$markersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MarkersRef = AutoDisposeProviderRef<Set<Marker>>;
String _$polylinesHash() => r'fc6b1dfab91d87c4074fb9e38e1a64bef4840c3c';

/// See also [polylines].
@ProviderFor(polylines)
final polylinesProvider = AutoDisposeProvider<Set<Polyline>>.internal(
  polylines,
  name: r'polylinesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$polylinesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PolylinesRef = AutoDisposeProviderRef<Set<Polyline>>;
String _$initialLocationHash() => r'b4bbe88e1d95c9387ef17f540801f048771fbce5';

/// See also [initialLocation].
@ProviderFor(initialLocation)
final initialLocationProvider = AutoDisposeFutureProvider<LatLng>.internal(
  initialLocation,
  name: r'initialLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InitialLocationRef = AutoDisposeFutureProviderRef<LatLng>;
String _$currentLocationHash() => r'933fccdd78e3bcd2013c3113e94aa78f91ddad4d';

/// See also [currentLocation].
@ProviderFor(currentLocation)
final currentLocationProvider = AutoDisposeStreamProvider<LatLng?>.internal(
  currentLocation,
  name: r'currentLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentLocationRef = AutoDisposeStreamProviderRef<LatLng?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
