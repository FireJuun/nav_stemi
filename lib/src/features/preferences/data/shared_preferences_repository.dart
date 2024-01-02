import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_repository.g.dart';

/// original source: https://github.com/MayJuun/wvems_protocols/tree/main/lib/src/features/preferences

enum _StoredValues {
  appTheme,
}

class SharedPreferencesRepository {
  SharedPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<void> reload() async => _prefs.reload();

  void saveAppTheme(AppTheme? appTheme) {
    if (appTheme == null) {
      _prefs.remove(_StoredValues.appTheme.name);
    } else {
      _prefs.setString(_StoredValues.appTheme.name, appTheme.toJson());
    }
  }

  AppTheme getAppTheme() {
    final appThemeString = _prefs.getString(_StoredValues.appTheme.name);
    if (appThemeString != null) {
      return AppTheme.fromJson(appThemeString);
    } else {
      return kFirstAppTheme;
    }
  }
}

@Riverpod(keepAlive: true)
SharedPreferencesRepository sharedPreferencesRepository(
  SharedPreferencesRepositoryRef ref,
) {
  // needs to be set in bootstrap
  throw UnimplementedError();
}
