import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/utils/result.dart';

void main() {
  group('Result', () {
    group('Basic functionality', () {
      test('creates success result', () {
        const result = Result<int, String>.success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.valueOrNull, equals(42));
        expect(result.errorOrNull, isNull);
      });

      test('creates failure result', () {
        const result = Result<int, String>.failure('error');
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.valueOrNull, isNull);
        expect(result.errorOrNull, equals('error'));
      });
    });

    group('Static factory methods', () {
      test('tryCatch handles success', () {
        final result = Result.tryCatch<int, String>(
          () => 42,
          onError: (error, stackTrace) => 'Error: $error',
        );
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(42));
      });

      test('tryCatch handles failure', () {
        final result = Result.tryCatch<int, String>(
          () => throw Exception('test error'),
          onError: (error, stackTrace) => 'Error: $error',
        );
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('test error'));
      });

      test('tryCatchSimple handles success', () {
        final result = Result.tryCatchSimple(() => 42);
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(42));
      });

      test('tryCatchSimple handles failure', () {
        final result = Result.tryCatchSimple<int>(
          () => throw Exception('test'),
        );
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('test'));
      });

      test('fromFuture handles success', () async {
        final result = await Result.fromFuture<int, String>(
          Future.value(42),
          onError: (error, stackTrace) => 'Error: $error',
        );
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(42));
      });

      test('fromFuture handles failure', () async {
        final result = await Result.fromFuture<int, String>(
          Future.error(Exception('test error')),
          onError: (error, stackTrace) => 'Error: $error',
        );
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('test error'));
      });
    });

    group('Transformation methods', () {
      test('map transforms success value', () {
        const result = Result<int, String>.success(42);
        final mapped = result.map((value) => value.toString());
        expect(mapped.valueOrNull, equals('42'));
      });

      test('map preserves failure', () {
        const result = Result<int, String>.failure('error');
        final mapped = result.map((value) => value.toString());
        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull, equals('error'));
      });

      test('flatMap chains successful operations', () {
        const result = Result<int, String>.success(42);
        final chained = result.flatMap(
          (value) => Result<String, String>.success(value.toString()),
        );
        expect(chained.valueOrNull, equals('42'));
      });

      test('flatMap short-circuits on failure', () {
        const result = Result<int, String>.failure('error');
        final chained = result.flatMap(
          (value) => Result<String, String>.success(value.toString()),
        );
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull, equals('error'));
      });
    });

    group('New utility methods', () {
      test('filter keeps matching values', () {
        const result = Result<int, String>.success(42);
        final filtered = result.filter(
          (value) => value > 40,
          () => 'Value too small',
        );
        expect(filtered.isSuccess, isTrue);
        expect(filtered.valueOrNull, equals(42));
      });

      test('filter rejects non-matching values', () {
        const result = Result<int, String>.success(42);
        final filtered = result.filter(
          (value) => value > 50,
          () => 'Value too small',
        );
        expect(filtered.isFailure, isTrue);
        expect(filtered.errorOrNull, equals('Value too small'));
      });

      test('swap exchanges success and failure', () {
        const success = Result<int, String>.success(42);
        final swapped = success.swap();
        expect(swapped.isFailure, isTrue);
        expect(swapped.errorOrNull, equals(42));

        const failure = Result<int, String>.failure('error');
        final swappedFailure = failure.swap();
        expect(swappedFailure.isSuccess, isTrue);
        expect(swappedFailure.valueOrNull, equals('error'));
      });

      test('contains checks for specific values', () {
        const result = Result<int, String>.success(42);
        expect(result.contains(42), isTrue);
        expect(result.contains(43), isFalse);

        const failure = Result<int, String>.failure('error');
        expect(failure.contains(42), isFalse);
      });

      test('containsError checks for specific errors', () {
        const result = Result<int, String>.failure('error');
        expect(result.containsError('error'), isTrue);
        expect(result.containsError('other'), isFalse);

        const success = Result<int, String>.success(42);
        expect(success.containsError('error'), isFalse);
      });
    });

    group('Combination methods', () {
      test('combine2 combines two successful results', () {
        const result1 = Result<int, String>.success(1);
        const result2 = Result<int, String>.success(2);
        final combined = Result.combine2(result1, result2);
        expect(combined.isSuccess, isTrue);
        expect(combined.valueOrNull, equals((1, 2)));
      });

      test('combine2 fails if first result fails', () {
        const result1 = Result<int, String>.failure('error1');
        const result2 = Result<int, String>.success(2);
        final combined = Result.combine2(result1, result2);
        expect(combined.isFailure, isTrue);
        expect(combined.errorOrNull, equals('error1'));
      });

      test('combine3 combines three successful results', () {
        const result1 = Result<int, String>.success(1);
        const result2 = Result<int, String>.success(2);
        const result3 = Result<int, String>.success(3);
        final combined = Result.combine3(result1, result2, result3);
        expect(combined.isSuccess, isTrue);
        expect(combined.valueOrNull, equals((1, 2, 3)));
      });

      test('collect combines list of successful results', () {
        final results = [
          const Result<int, String>.success(1),
          const Result<int, String>.success(2),
          const Result<int, String>.success(3),
        ];
        final collected = Result.collect(results);
        expect(collected.isSuccess, isTrue);
        expect(collected.valueOrNull, equals([1, 2, 3]));
      });

      test('collect fails on first failure', () {
        final results = [
          const Result<int, String>.success(1),
          const Result<int, String>.failure('error'),
          const Result<int, String>.success(3),
        ];
        final collected = Result.collect(results);
        expect(collected.isFailure, isTrue);
      });
    });

    group('Extension methods', () {
      test('nullable to result conversion', () {
        const int? nullableValue = 42;
        final result = nullableValue.toResult(() => 'null error');
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(42));

        const int? nullValue = null;
        final nullResult = nullValue.toResult(() => 'null error');
        expect(nullResult.isFailure, isTrue);
        expect(nullResult.errorOrNull, equals('null error'));
      });

      test('nullable to result simple conversion', () {
        const int? nullableValue = 42;
        final result = nullableValue.toResultSimple();
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, equals(42));

        const int? nullValue = null;
        final nullResult = nullValue.toResultSimple('Custom error');
        expect(nullResult.isFailure, isTrue);
        expect(nullResult.errorOrNull, equals('Custom error'));
      });
    });

    group('Async extensions', () {
      test('Future<Result> mapSuccess', () async {
        final futureResult = Future.value(
          const Result<int, String>.success(42),
        );
        final mapped = await futureResult.mapSuccess(
          (value) => value.toString(),
        );
        expect(mapped.valueOrNull, equals('42'));
      });

      test('Future<Result> timeoutWithResult', () async {
        final slowFuture = Future.delayed(
          const Duration(seconds: 2),
          () => const Result<int, String>.success(42),
        );
        final result = await slowFuture.timeoutWithResult(
          const Duration(milliseconds: 100),
          () => 'Timeout error',
        );
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals('Timeout error'));
      });
    });
  });
}
