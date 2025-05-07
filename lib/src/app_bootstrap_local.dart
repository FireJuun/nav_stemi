import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
///
class AppBootstrapLocal extends AppBootstrap {
  /// Creates the top-level [ProviderContainer] by overriding providers with
  /// real or fake repositories. This is useful for testing purposes and for
  /// running the app with a "fake" backend.
  ///
  /// Note: all repositories needed by the app can be accessed via providers.
  /// Some of these providers throw an [UnimplementedError] by default.
  ///
  /// Example:
  /// ```dart
  /// @Riverpod(keepAlive: true)
  /// SomeRepository someRepository(SomeRepositoryRef ref) {
  ///   throw UnimplementedError();
  /// }
  /// ```
  ///
  /// As a result, this method does two things:
  /// - create and configure the repositories as desired
  /// - override the default implementations with a list of "overrides"
  ///
  Future<ProviderContainer> createLocalProviderContainer({
    bool addDelay = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedPreferencesRepository = SharedPreferencesRepository(prefs);

    // Get package info to detect environment
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final isStaging = packageName.endsWith('.stg');

    // Choose the appropriate authentication repository based on environment
    final AuthRepository authRepository;
    if (isStaging) {
      // Use fake auth for staging
      authRepository = FakeAuthRepository();
    } else if (Env.serviceAccountEmail.isNotEmpty &&
        Env.serviceAccountPrivateKey.isNotEmpty) {
      // Use service account when credentials are available
      authRepository = TestAuthRepository();
    } else {
      // Otherwise use Google auth
      authRepository = GoogleAuthRepository();
    }

    // Initialize Firebase Auth service for anonymous authentication
    final firebaseAuthRepository = FirebaseAuthRepository();

    final lastTheme = sharedPreferencesRepository.getAppTheme();
    final themeRepository = ThemeRepository(lastTheme);
    final navigationSettings =
        sharedPreferencesRepository.getNavigationSettings();
    final navigationSettingsRepository =
        NavigationSettingsRepository(navigationSettings);

    /// Swap between Mapbox <-> Google for app routing
    final remoteRoutes = RemoteRoutesGoogleRepository();

    // Create list of provider overrides
    final overrides = [
      // repositories
      authRepositoryProvider.overrideWithValue(authRepository),
      firebaseAuthRepositoryProvider.overrideWithValue(firebaseAuthRepository),
      sharedPreferencesRepositoryProvider
          .overrideWithValue(sharedPreferencesRepository),
      navigationSettingsRepositoryProvider
          .overrideWithValue(navigationSettingsRepository),
      themeRepositoryProvider.overrideWithValue(themeRepository),
      remoteRoutesRepositoryProvider.overrideWithValue(remoteRoutes),
    ];

    // For staging environment, use fake FHIR services
    if (isStaging) {
      overrides.addAll([
        // Use fake FHIR service
        fhirServiceProvider.overrideWith(fakeFhirService),
        // Use fake FHIR sync service
        fhirSyncServiceProvider.overrideWith(fakeFhirSyncService),
        // Use fake FHIR sync status providers
        patientInfoSyncStatusRepositoryProvider
            .overrideWith(fakePatientInfoSyncStatusRepository),
        timeMetricsSyncStatusRepositoryProvider
            .overrideWith(fakeTimeMetricsSyncStatusRepository),
        patientInfoSyncStatusProvider.overrideWith(fakePatientInfoSyncStatus),
        timeMetricsSyncStatusProvider.overrideWith(fakeTimeMetricsSyncStatus),
        overallSyncStatusProvider.overrideWith(fakeOverallSyncStatus),
        syncLastErrorMessageProvider.overrideWith(fakeSyncLastErrorMessage),
      ]);
    }

    return ProviderContainer(
      overrides: overrides,
      observers: [
        AsyncErrorLogger(),
      ],
    );
  }
}
