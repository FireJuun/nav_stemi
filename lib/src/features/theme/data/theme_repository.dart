import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_repository.g.dart';

/// source: https://github.com/MayJuun/wvems_protocols/tree/main/lib/src/features/theme

class ThemeRepository {
  ThemeRepository(this._lastTheme);

  /// This is loaded from local storage, if that has been set
  final AppTheme _lastTheme;

  /// Auto-rebuild UI when theme settings or colors change
  ///
  late final _appTheme = InMemoryStore<AppTheme>(_lastTheme);

  Stream<AppTheme> get appThemeChanges => _appTheme.stream;

  /// Used to modify entire app theme, or manually set each part
  ///
  // ignore: use_setters_to_change_properties
  void setAppTheme(AppTheme newValue) => _appTheme.value = newValue;
  void setAppThemeMode(ThemeMode newValue) => _appTheme.value =
      AppTheme(themeMode: newValue, seedColor: _appTheme.value.seedColor);
  void setAppSeedColor(Color newValue) => _appTheme.value =
      AppTheme(themeMode: _appTheme.value.themeMode, seedColor: newValue);

  /// Set light and dark modes, which currently differ only by brightness
  ///
  ThemeData get lightTheme => _themeData(Brightness.light);
  ThemeData get darkTheme => _themeData(Brightness.dark);

  /// Custom theme settings, imported throughout the app
  ///
  ThemeData _themeData(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _appTheme.value.seedColor,
      brightness: brightness,
    );

    final textTheme = _buildTextTheme();
    return ThemeData(
      textTheme: textTheme,
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        titleTextStyle: textTheme.displaySmall?.apply(
          color: colorScheme.onBackground,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        menuStyle: const MenuStyle(
          visualDensity: VisualDensity.compact,
          padding: MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle:
            textTheme.bodySmall!.apply(color: colorScheme.onPrimaryContainer),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            textTheme.titleMedium!,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            textTheme.titleMedium!,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        smallSizeConstraints: BoxConstraints(minWidth: 48, minHeight: 48),
      ),
      scrollbarTheme: ScrollbarThemeData(
        interactive: true,
        thumbVisibility: MaterialStateProperty.all(true),
        trackVisibility: MaterialStateProperty.all(true),
        thickness: MaterialStateProperty.all(8),
      ),
    );
  }
}

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: _style(96, FontWeight.normal),
    displayMedium: _style(60, FontWeight.bold),
    displaySmall: _style(44, FontWeight.w600),
    headlineMedium: _style(36, FontWeight.bold),
    headlineSmall: _style(22, FontWeight.w500),
    titleLarge: _style(36, FontWeight.w500),
    titleMedium: _style(24, FontWeight.w500).apply(fontStyle: FontStyle.italic),
    titleSmall: _style(16, FontWeight.w300),
    bodyLarge: _style(20, FontWeight.normal),
    bodyMedium: _style(18, FontWeight.normal),
    bodySmall: _style(12, FontWeight.normal),
    labelLarge: _style(18, FontWeight.normal),
    labelSmall: _style(12, FontWeight.normal),
  );
}

TextStyle _style(double s, FontWeight w) =>
    TextStyle(fontSize: s, fontWeight: w);

@Riverpod(keepAlive: true)
ThemeRepository themeRepository(ThemeRepositoryRef ref) {
  // set this in the app bootstrap section
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Stream<AppTheme> appThemeChanges(AppThemeChangesRef ref) {
  final themeRepository = ref.watch(themeRepositoryProvider);
  return themeRepository.appThemeChanges;
}

// spec: https://api.flutter.dev/flutter/material/MaterialStateProperty-class.html
const Set<MaterialState> interactiveStates = <MaterialState>{
  MaterialState.pressed,
  MaterialState.hovered,
  MaterialState.focused,
};

const Set<MaterialState> activeStates = <MaterialState>{
  MaterialState.selected,
};
