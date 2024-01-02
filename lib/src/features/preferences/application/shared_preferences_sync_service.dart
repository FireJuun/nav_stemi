import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_preferences_sync_service.g.dart';

/// original source: https://github.com/MayJuun/wvems_protocols/tree/main/lib/src/features/preferences

/// Listens for any changes to parts of the app that
/// need to be stored locally. If those occur, then this
/// service will automatically sync that new change.
class SharedPreferencesSyncService {
  SharedPreferencesSyncService(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() {
    /// Listen for changes to the active PDF,
    /// then save a reference in local storage
    ref

        /// Listen for changes to the current app theme,
        /// then save a reference in local storage
        .listen<AsyncValue<AppTheme>>(appThemeChangesProvider,
            (previous, next) {
      final appTheme = next.value;
      if (previous is AsyncLoading) {
        // do nothing
      } else {
        _saveAppThemeLocally(appTheme);
      }
    });
  }

  Future<void> _saveAppThemeLocally(AppTheme? appTheme) async {
    ref.read(sharedPreferencesRepositoryProvider).saveAppTheme(appTheme);
  }
}

@Riverpod(keepAlive: true)
SharedPreferencesSyncService sharedPreferencesSyncService(
  SharedPreferencesSyncServiceRef ref,
) {
  return SharedPreferencesSyncService(ref);
}
