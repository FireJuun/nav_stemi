// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_environment.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appEnvironmentConfigHash() =>
    r'e0b281871e1b06667e32f8daf40257b48dfc0942';

/// Provider for environment configuration
/// This will be initialized only once and kept alive throughout
/// the app's lifecycle
///
/// Copied from [appEnvironmentConfig].
@ProviderFor(appEnvironmentConfig)
final appEnvironmentConfigProvider =
    FutureProvider<AppEnvironmentConfig>.internal(
  appEnvironmentConfig,
  name: r'appEnvironmentConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appEnvironmentConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppEnvironmentConfigRef = FutureProviderRef<AppEnvironmentConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
