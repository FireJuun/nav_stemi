// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fhir_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fhirSyncServiceHash() => r'ad27f5d6ced768a3f2012253680c930206b2a47c';

/// Provides the FHIR sync service
///
/// Copied from [fhirSyncService].
@ProviderFor(fhirSyncService)
final fhirSyncServiceProvider = Provider<FhirSyncService>.internal(
  fhirSyncService,
  name: r'fhirSyncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fhirSyncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FhirSyncServiceRef = ProviderRef<FhirSyncService>;
String _$fhirPatientInfoSyncStatusHash() =>
    r'03800016c988da910c63fc83f7e74cd0b2cc185c';

/// Provides the status of patient info sync
///
/// Copied from [fhirPatientInfoSyncStatus].
@ProviderFor(fhirPatientInfoSyncStatus)
final fhirPatientInfoSyncStatusProvider = Provider<FhirSyncStatus>.internal(
  fhirPatientInfoSyncStatus,
  name: r'fhirPatientInfoSyncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fhirPatientInfoSyncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FhirPatientInfoSyncStatusRef = ProviderRef<FhirSyncStatus>;
String _$fhirTimeMetricsSyncStatusHash() =>
    r'14c915760995c28eba145b33326258c3305c1605';

/// Provides the status of time metrics sync
///
/// Copied from [fhirTimeMetricsSyncStatus].
@ProviderFor(fhirTimeMetricsSyncStatus)
final fhirTimeMetricsSyncStatusProvider = Provider<FhirSyncStatus>.internal(
  fhirTimeMetricsSyncStatus,
  name: r'fhirTimeMetricsSyncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fhirTimeMetricsSyncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FhirTimeMetricsSyncStatusRef = ProviderRef<FhirSyncStatus>;
String _$fhirOverallSyncStatusHash() =>
    r'e747dffb82ae79d6054ee84dd64d09a8885c888f';

/// Provides the overall sync status (combined from patient info and time metrics)
///
/// Copied from [fhirOverallSyncStatus].
@ProviderFor(fhirOverallSyncStatus)
final fhirOverallSyncStatusProvider = Provider<FhirSyncStatus>.internal(
  fhirOverallSyncStatus,
  name: r'fhirOverallSyncStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fhirOverallSyncStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FhirOverallSyncStatusRef = ProviderRef<FhirSyncStatus>;
String _$fhirSyncLastErrorMessageHash() =>
    r'7154b9ab522b0a0af4db58186404e3060e3cad35';

/// Provides the last error message from sync operations
///
/// Copied from [fhirSyncLastErrorMessage].
@ProviderFor(fhirSyncLastErrorMessage)
final fhirSyncLastErrorMessageProvider = Provider<String?>.internal(
  fhirSyncLastErrorMessage,
  name: r'fhirSyncLastErrorMessageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fhirSyncLastErrorMessageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FhirSyncLastErrorMessageRef = ProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
