import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_repository.g.dart';

/// original source: https://github.com/MayJuun/wvems_protocols/tree/main/lib/src/features/preferences

enum _StoredValues { appTheme, navigationSettings, autoSyncPeers }

class SharedPreferencesRepository {
  SharedPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<void> reload() async => _prefs.reload();

  List<String> getAutoSyncPeers() {
    return _prefs.getStringList(_StoredValues.autoSyncPeers.name) ?? [];
  }

  void addAutoSyncPeer(String peerId) {
    final peers =
        _prefs.getStringList(_StoredValues.autoSyncPeers.name)?.toSet() ?? {}
          ..add(peerId);

    _prefs.setStringList(_StoredValues.autoSyncPeers.name, peers.toList());
  }

  void removeAutoSyncPeer(String peerId) {
    final peers =
        _prefs
            .getStringList(_StoredValues.autoSyncPeers.name)
            ?.where((e) => e != peerId)
            .toSet() ??
        {};

    _prefs.setStringList(_StoredValues.autoSyncPeers.name, peers.toList());
  }

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

  void saveNavigationSettings(NavigationSettings? navigationSettings) {
    if (navigationSettings == null) {
      _prefs.remove(_StoredValues.navigationSettings.name);
    } else {
      _prefs.setString(
        _StoredValues.navigationSettings.name,
        navigationSettings.toJson(),
      );
    }
  }

  NavigationSettings getNavigationSettings() {
    final navigationSettingsString = _prefs.getString(
      _StoredValues.navigationSettings.name,
    );
    if (navigationSettingsString != null) {
      return NavigationSettings.fromJson(navigationSettingsString);
    } else {
      return kDefaultNavigationSettings;
    }
  }
}

@Riverpod(keepAlive: true)
SharedPreferencesRepository sharedPreferencesRepository(Ref ref) {
  // needs to be set in bootstrap
  throw UnimplementedError();
}
