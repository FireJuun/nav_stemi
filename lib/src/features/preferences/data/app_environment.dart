import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_environment.g.dart';

/// Enum representing the different environments the app can run in
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Class to handle environment-specific utilities
class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    required this.packageInfo,
  });

  /// The current environment the app is running in
  final AppEnvironment environment;

  /// Package info for version information
  final PackageInfo packageInfo;

  /// Get the app version
  String get version => packageInfo.version;

  /// Get the app build number
  String get buildNumber => packageInfo.buildNumber;

  /// Get the full version string (version+buildNumber)
  String get fullVersion => '$version+$buildNumber';

  /// Get the appropriate AppBar color for the current environment
  /// Production: Default (system color)
  /// Staging: Red (hex 941C1C)
  /// Development: Blue (hex 1C4294)
  Color getAppBarColor() {
    switch (environment) {
      case AppEnvironment.development:
        return const Color(0xFF1C4294); // Blue for dev
      case AppEnvironment.staging:
        return const Color(0xFF941C1C); // Red for staging
      case AppEnvironment.production:
        return Colors.transparent; // Default theme color for production
    }
  }
}

/// Provider for environment configuration
/// This will be initialized only once and kept alive throughout
/// the app's lifecycle
@Riverpod(keepAlive: true)
FutureOr<AppEnvironmentConfig> appEnvironmentConfig(Ref ref) async {
  // Get package info
  final packageInfo = await PackageInfo.fromPlatform();

  // Detect environment based on package name suffix
  final packageName = packageInfo.packageName;

  AppEnvironment environment;
  if (packageName.endsWith('.dev')) {
    environment = AppEnvironment.development;
  } else if (packageName.endsWith('.stg')) {
    environment = AppEnvironment.staging;
  } else {
    environment = AppEnvironment.production;
  }

  return AppEnvironmentConfig(
    environment: environment,
    packageInfo: packageInfo,
  );
}
