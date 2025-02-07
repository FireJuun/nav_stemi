// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allHospitalsHash() => r'0e45940b8086d5884f00aeb55fc49fd6dbbb5324';

/// See also [allHospitals].
@ProviderFor(allHospitals)
final allHospitalsProvider = AutoDisposeProvider<List<Hospital>>.internal(
  allHospitals,
  name: r'allHospitalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allHospitalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllHospitalsRef = AutoDisposeProviderRef<List<Hospital>>;
String _$nearbyHospitalsHash() => r'57f3ce3fbca48cd853c8f7d2c7f663856881ad8c';

/// See also [nearbyHospitals].
@ProviderFor(nearbyHospitals)
final nearbyHospitalsProvider =
    AutoDisposeFutureProvider<NearbyHospitals>.internal(
  nearbyHospitals,
  name: r'nearbyHospitalsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nearbyHospitalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NearbyHospitalsRef = AutoDisposeFutureProviderRef<NearbyHospitals>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
