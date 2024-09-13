/// Mixin to be added to Notifier subclasses
/// Use this mixin if you need to check if the Notifier is mounted before
/// setting the state (usually, following an asynchronous operation).
///
/// Original spec: https://codewithandrea.com/articles/async-notifier-mounted-riverpod/
/// Using bool is less idea, as noted here:
/// https://github.com/rrousselGit/riverpod/issues/1879
///
/// Thus, this mixin was modified to include object instead of bool
///
///
/// Example usage:
///
/// ```dart
/// @riverpod
/// class SomeNotifier extends _$SomeNotifier with NotifierMounted {
///   @override
///   FutureOr<void> build() {
///     ref.onDispose(setUnmounted);
///   }
///   Future<void> doAsyncWork() {
///     state = const AsyncLoading();
///     final newState = await AsyncValue.guard(someFuture);
///     if (mounted) {
///       state = newState;
///     }
///   }
/// }
///
library;

mixin NotifierMounted {
  final initial = Object();
  late Object current = initial;
  // An [Object] instance is equal to itself only.
  bool get mounted => current == initial;

  // By creating a new [Object] instance, mounted should no longer be true
  void setUnmounted() => current = Object();
}
