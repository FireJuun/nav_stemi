# NAV-STEMI Flutter Project Guide

## Commands

- **Build:** `flutter build apk/ios/web --flavor [development/staging/production]`
- **Run:** `flutter run --flavor [development/staging/production]`
- **Code Generation:** `dart run build_runner build --delete-conflicting-outputs`
- **Lint:** `flutter analyze`
- **Run Tests:** `flutter test`
- **Run Single Test:** `flutter test test/path/to/test.dart`
- **Launcher Icons:** `flutter pub run flutter_launcher_icons -f flutter_launcher_icons-[environment].yaml`
- **Update Splash:** `flutter pub run flutter_native_splash:create`

## Code Style Guidelines

- **Architecture:** Feature-first structure with Riverpod for state management
- **Code Generation:** Use Riverpod annotations (@riverpod) and build_runner
- **Imports:** Group by package, then relative paths; use export files
- **Error Handling:** Use AsyncValue and error handlers with errorLoggerProvider
- **Naming:** Camel case for variables/methods, Pascal case for classes/types
- **Types:** Use strong typing with nullable annotations when appropriate
- **UI Components:** Riverpod with controllers when needed
- **Style Guide:** Based on very_good_analysis package
- **Directory Structure:** src/features/{feature}/{application|data|domain|presentation}
- **State Management:** Riverpod with proper provider scoping and dependency injection
