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
String _$originHash() => r'd91996646de6f717782ec4ea4b3f825d205ea41f';

/// See also [origin].
@ProviderFor(origin)
final originProvider = AutoDisposeProvider<LatLng>.internal(
  origin,
  name: r'originProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$originHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OriginRef = AutoDisposeProviderRef<LatLng>;
String _$destinationHash() => r'b663e5b2c3e4e23fe50b98b0b5224d66478224f5';

/// See also [destination].
@ProviderFor(destination)
final destinationProvider = AutoDisposeProvider<LatLng>.internal(
  destination,
  name: r'destinationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$destinationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DestinationRef = AutoDisposeProviderRef<LatLng>;
String _$markersHash() => r'95fc81e5fd42ed996f0f00caf7d107c100f4224e';

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
String _$polylinesHash() => r'437aef866602dd22e96ef70907d6bdef2dc23b7d';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
