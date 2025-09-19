import 'dart:async';

import 'package:equatable/equatable.dart';

/// A sealed Result class that represents either a success or failure
sealed class Result<T, E> extends Equatable {
  const Result();

  /// Create a successful result
  const factory Result.success(T value) = Success<T, E>;

  /// Create a failure result
  const factory Result.failure(E error) = Failure<T, E>;

  /// Create a Result from a function that might throw
  static Result<T, E> tryCatch<T, E>(
    T Function() fn, {
    required E Function(Object error, StackTrace? stackTrace) onError,
  }) {
    try {
      return Result.success(fn());
    } catch (error, stackTrace) {
      return Result.failure(onError(error, stackTrace));
    }
  }

  /// Create a Result from a function that might throw, with a simple error type
  static Result<T, String> tryCatchSimple<T>(T Function() fn) {
    try {
      return Result.success(fn());
    } catch (error) {
      return Result.failure('$error');
    }
  }

  /// Combine two Results into a tuple Result
  static Result<(T1, T2), E> combine2<T1, T2, E>(
    Result<T1, E> result1,
    Result<T2, E> result2,
  ) {
    return result1.flatMap(
      (value1) => result2.map((value2) => (value1, value2)),
    );
  }

  /// Combine three Results into a tuple Result
  static Result<(T1, T2, T3), E> combine3<T1, T2, T3, E>(
    Result<T1, E> result1,
    Result<T2, E> result2,
    Result<T3, E> result3,
  ) {
    return result1.flatMap(
      (value1) => result2.flatMap(
        (value2) => result3.map((value3) => (value1, value2, value3)),
      ),
    );
  }

  /// Collect a list of Results into a Result of a list
  /// Returns the first failure encountered, or success with all values
  static Result<List<T>, E> collect<T, E>(List<Result<T, E>> results) {
    final values = <T>[];
    for (final result in results) {
      switch (result) {
        case Success(:final value):
          values.add(value);
        case Failure():
          return result.map((_) => <T>[]);
      }
    }
    return Result.success(values);
  }

  /// Create a Result from a Future that might throw
  static Future<Result<T, E>> fromFuture<T, E>(
    Future<T> future, {
    required E Function(Object error, StackTrace? stackTrace) onError,
  }) async {
    try {
      final value = await future;
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(onError(error, stackTrace));
    }
  }

  /// Check if the result is a success
  bool get isSuccess => this is Success<T, E>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure<T, E>;

  /// Get the value if success, null otherwise
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Get the error if failure, null otherwise
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Get the value or a default value
  T getOrElse(T defaultValue) => switch (this) {
    Success(:final value) => value,
    Failure() => defaultValue,
  };

  /// Get the value or compute a default value
  T getOrElseGet(T Function() defaultValue) => switch (this) {
    Success(:final value) => value,
    Failure() => defaultValue(),
  };

  /// Get the value or throw the error
  T getOrThrow() => switch (this) {
    Success(:final value) => value,
    Failure(:final error) =>
      throw error is Exception ? error : Exception('Result failure: $error'),
  };

  /// Transform the success value
  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Result.success(transform(value)),
    Failure(:final error) => Result.failure(error),
  };

  /// Transform the error value
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
    Success(:final value) => Result.success(value),
    Failure(:final error) => Result.failure(transform(error)),
  };

  /// Transform the success value with a function that returns a Result
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Result.failure(error),
      };

  /// Handle both success and failure cases
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final error) => onFailure(error),
  };

  /// Execute a side effect if success
  Result<T, E> onSuccess(void Function(T value) action) {
    if (this case Success(:final value)) {
      action(value);
    }
    // ignore: avoid_returning_this
    return this;
  }

  /// Execute a side effect if failure
  Result<T, E> onFailure(void Function(E error) action) {
    if (this case Failure(:final error)) {
      action(error);
    }
    // ignore: avoid_returning_this
    return this;
  }

  /// Pattern matching with when
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) => switch (this) {
    Success(:final value) => success(value),
    Failure(:final error) => failure(error),
  };

  /// Convert to an Either type (if you have one)
  (T?, E?) toEither() => switch (this) {
    Success(:final value) => (value, null),
    Failure(:final error) => (null, error),
  };

  /// Recover from a failure
  Result<T, E> recover(T Function(E error) recovery) => switch (this) {
    Success() => this,
    Failure(:final error) => Result.success(recovery(error)),
  };

  /// Recover from a failure with a Result
  Result<T, E> recoverWith(Result<T, E> Function(E error) recovery) =>
      switch (this) {
        Success() => this,
        Failure(:final error) => recovery(error),
      };

  /// Filter the success value with a predicate
  Result<T, E> filter(bool Function(T value) predicate, E Function() onFalse) =>
      switch (this) {
        Success(:final value) when predicate(value) => this,
        Success() => Result.failure(onFalse()),
        Failure() => this,
      };

  /// Swap success and failure
  Result<E, T> swap() => switch (this) {
    Success(:final value) => Result.failure(value),
    Failure(:final error) => Result.success(error),
  };

  /// Check if the result contains a specific value
  bool contains(T targetValue) => switch (this) {
    Success(:final value) => value == targetValue,
    Failure() => false,
  };

  /// Check if the result contains a specific error
  bool containsError(E targetError) => switch (this) {
    Success() => false,
    Failure(:final error) => error == targetError,
  };

  @override
  bool? get stringify => true;
}

/// Represents a successful result
final class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;

  @override
  List<Object?> get props => [value];
}

/// Represents a failure result
final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;

  @override
  List<Object?> get props => [error];
}

/// Extension methods for Result with async operations
extension ResultAsync<T, E> on Result<T, E> {
  /// Async map
  Future<Result<R, E>> mapAsync<R>(
    Future<R> Function(T value) transform,
  ) async => switch (this) {
    Success(:final value) => Result.success(await transform(value)),
    Failure(:final error) => Result.failure(error),
  };

  /// Async flatMap
  Future<Result<R, E>> flatMapAsync<R>(
    Future<Result<R, E>> Function(T value) transform,
  ) async => switch (this) {
    Success(:final value) => await transform(value),
    Failure(:final error) => Result.failure(error),
  };
}

/// Extension methods for Future<Result>
extension FutureResultExtension<T, E> on Future<Result<T, E>> {
  /// Map the success value of a Future<Result>
  Future<Result<R, E>> mapSuccess<R>(R Function(T value) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// FlatMap the success value of a Future<Result>
  Future<Result<R, E>> flatMapSuccess<R>(
    Result<R, E> Function(T value) transform,
  ) async {
    final result = await this;
    return result.flatMap(transform);
  }

  /// Handle errors in the Future itself and convert to Result
  Future<Result<T, E>> onError(
    E Function(Object error, StackTrace? stackTrace) onError,
  ) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      return Result.failure(onError(error, stackTrace));
    }
  }

  /// Timeout with a Result failure
  Future<Result<T, E>> timeoutWithResult(
    Duration timeout,
    E Function() onTimeout,
  ) async {
    try {
      return await this.timeout(timeout);
    } on TimeoutException {
      return Result.failure(onTimeout());
    }
  }
}

/// Extension methods for nullable values
extension NullableToResult<T extends Object> on T? {
  /// Convert a nullable value to a Result
  Result<T, E> toResult<E>(E Function() onNull) {
    return this != null ? Result.success(this!) : Result.failure(onNull());
  }

  /// Convert a nullable value to a Result with a simple error message
  Result<T, String> toResultSimple([String? errorMessage]) {
    return this != null
        ? Result.success(this!)
        : Result.failure(errorMessage ?? 'Value is null');
  }
}
