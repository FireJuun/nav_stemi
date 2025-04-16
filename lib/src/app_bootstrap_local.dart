import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
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

    // TODO(FireJuun): should this be somewhere else in the app?
    /// this will determine first login / verification of the user
    final authRepository = GoogleAuthRepository();

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

    return ProviderContainer(
      overrides: [
        // repositories
        authRepositoryProvider.overrideWithValue(authRepository),
        firebaseAuthRepositoryProvider
            .overrideWithValue(firebaseAuthRepository),
        sharedPreferencesRepositoryProvider
            .overrideWithValue(sharedPreferencesRepository),
        navigationSettingsRepositoryProvider
            .overrideWithValue(navigationSettingsRepository),
        themeRepositoryProvider.overrideWithValue(themeRepository),
        remoteRoutesRepositoryProvider.overrideWithValue(remoteRoutes),
      ],
      observers: [
        AsyncErrorLogger(),
      ],
    );
  }
}
