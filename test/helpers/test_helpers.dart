import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] for testing
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
  );

  addTearDown(container.dispose);

  return container;
}

/// Helper extension for async testing
extension AsyncValueTestExtensions<T> on AsyncValue<T> {
  T get requireValue {
    return when(
      data: (value) => value,
      loading: () => throw AssertionError('Expected data, got loading'),
      error: (error, _) =>
          throw AssertionError('Expected data, got error: $error'),
    );
  }

  Object get requireError {
    return when(
      data: (_) => throw AssertionError('Expected error, got data'),
      loading: () => throw AssertionError('Expected error, got loading'),
      error: (error, _) => error,
    );
  }

  bool get isLoading => when(
        data: (_) => false,
        loading: () => true,
        error: (_, __) => false,
      );
}

/// Common test matchers
Matcher throwsAssertionError = throwsA(isA<AssertionError>());

/// Creates a provider scope for widget testing
ProviderScope createProviderScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: child,
  );
}
