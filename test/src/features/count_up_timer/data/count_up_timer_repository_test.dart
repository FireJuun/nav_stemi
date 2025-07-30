import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/count_up_timer/data/count_up_timer_repository.dart';

void main() {
  group('CountUpTimerRepository', () {
    late CountUpTimerRepository repository;

    setUp(() {
      repository = CountUpTimerRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('should emit initial value of 0', () async {
      final firstValue = await repository.timerStream.first;
      expect(firstValue, equals(0));
    });

    test('should start and emit incremented values', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      repository.start();

      // Wait for at least 3 emissions (0, 1, 2)
      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 100));

      await subscription.cancel();

      // Should have initial 0 plus at least 3 more values
      expect(values.length, greaterThanOrEqualTo(4));
      expect(values.first, equals(0));
      
      // Verify values are incrementing
      for (var i = 1; i < values.length; i++) {
        expect(values[i], equals(values[i - 1] + 1));
      }
    });

    test('should stop timer when stop is called', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      repository.start();

      // Let it run for 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 100));

      repository.stop();
      final valueAfterStop = values.last;

      // Wait another 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2));

      await subscription.cancel();

      // All values after stop should be the same
      final valuesAfterStop = values.where((v) => v > valueAfterStop).toList();
      expect(valuesAfterStop, isEmpty);
    });

    test('should reset timer to 0', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      repository.start();

      // Let it run for 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 100));

      await repository.reset();

      // Wait a bit to ensure the reset value is emitted
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await subscription.cancel();

      // Last value should be 0
      expect(values.last, equals(0));
    });

    test('should set elapsed time correctly', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      await repository.setElapsedTime(100);

      // Wait for emission
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await subscription.cancel();

      expect(values.last, equals(100));
    });

    test('should continue from offset after setting elapsed time', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      await repository.setElapsedTime(100);
      repository.start();

      // Wait for 2 seconds
      await Future<void>.delayed(const Duration(seconds: 2, milliseconds: 100));

      await subscription.cancel();

      // Should have values starting from 100
      expect(values.contains(100), isTrue);
      expect(values.contains(101), isTrue);
      expect(values.contains(102), isTrue);
    });

    test(
      'should restart timer if running when setting elapsed time',
      () async {
        final values = <int>[];
        final subscription = repository.timerStream.listen(values.add);

        repository.start();
        await repository.setElapsedTime(50);

        // Wait for timer to increment
        await Future<void>.delayed(
          const Duration(seconds: 2, milliseconds: 100),
        );

        await subscription.cancel();

        // Should have values incrementing from 50
        expect(values.contains(50), isTrue);
        
        // Check that we have values greater than 50
        final valuesAfter50 = values.where((v) => v > 50).toList();
        expect(valuesAfter50, isNotEmpty);
        
        // Verify they're incrementing
        for (var i = 1; i < valuesAfter50.length; i++) {
          expect(valuesAfter50[i], equals(valuesAfter50[i - 1] + 1));
        }
      },
    );

    test(
      'should not restart timer if stopped when setting elapsed time',
      () async {
        final values = <int>[];
        final subscription = repository.timerStream.listen(values.add);

        repository
          ..start()
          ..stop();
        
        await repository.setElapsedTime(50);

        // Wait to see if timer increments
        await Future<void>.delayed(const Duration(seconds: 2));

        await subscription.cancel();

        // Should stay at 50 (not incrementing)
        final valuesAfter50 = values.where((v) => v > 50).toList();
        expect(valuesAfter50, isEmpty);
      },
    );

    group('setTimerFromDateTime', () {
      test('should reset when startDateTime is null', () async {
        final values = <int>[];
        final subscription = repository.timerStream.listen(values.add);

        repository.start();
        await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));

        await repository.setTimerFromDateTime(null);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        expect(values.last, equals(0));
      });

      test(
        'should calculate elapsed time from startDateTime to now',
        () async {
          final values = <int>[];
          final subscription = repository.timerStream.listen(values.add);

        final startTime = DateTime.now().subtract(const Duration(seconds: 30));
        await repository.setTimerFromDateTime(startTime);

        await Future<void>.delayed(const Duration(milliseconds: 100));

          await subscription.cancel();

          // Should be approximately 30 seconds
          expect(values.last, greaterThanOrEqualTo(29));
          expect(values.last, lessThanOrEqualTo(31));
        },
      );

      test(
        'should calculate elapsed time between start and end times',
        () async {
          final values = <int>[];
          final subscription = repository.timerStream.listen(values.add);

        final startTime = DateTime(2024, 1, 1, 10);
        // 5 minutes 30 seconds later
        final endTime = DateTime(2024, 1, 1, 10, 5, 30);

        await repository.setTimerFromDateTime(
          startTime,
          endDateTime: endTime,
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));

          await subscription.cancel();

          expect(values.last, equals(330)); // 5 * 60 + 30
        },
      );

      test('should throw error if end time is before start time', () async {
        final startTime = DateTime.now();
        final endTime = startTime.subtract(const Duration(seconds: 10));

        expect(
          () => repository.setTimerFromDateTime(
            startTime,
            endDateTime: endTime,
          ),
          throwsArgumentError,
        );
      });

      test('should start timer when endDateTime is null', () async {
        final values = <int>[];
        final subscription = repository.timerStream.listen(values.add);

        final startTime = DateTime.now().subtract(
          const Duration(seconds: 10),
        );
        
        await repository.setTimerFromDateTime(startTime);

        // Wait to see if timer increments
        await Future<void>.delayed(
          const Duration(seconds: 2, milliseconds: 100),
        );

        await subscription.cancel();

        // Should have incrementing values
        final distinctValues = values.toSet().toList();
        expect(distinctValues.length, greaterThan(2));
      });

      test('should stop timer when endDateTime is provided', () async {
        final values = <int>[];
        final subscription = repository.timerStream.listen(values.add);

        final startTime = DateTime.now().subtract(
          const Duration(seconds: 10),
        );
        final endTime = DateTime.now();
        
        await repository.setTimerFromDateTime(
          startTime,
          endDateTime: endTime,
        );
        
        // Wait for the value to be emitted
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final valueAfterSet = values.last;

        // Wait to see if timer increments
        await Future<void>.delayed(const Duration(seconds: 2));

        await subscription.cancel();

        // Should not have changed
        expect(values.last, equals(valueAfterSet));
      });
    });

    test('should handle multiple start calls gracefully', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      repository.start();
      repository.start(); // Second start should not cause issues

      await Future<void>.delayed(const Duration(seconds: 1, milliseconds: 100));

      await subscription.cancel();

      // Should continue counting normally
      expect(values.contains(1), isTrue);
    });

    test('should handle multiple stop calls gracefully', () async {
      final values = <int>[];
      final subscription = repository.timerStream.listen(values.add);

      repository
        ..start()
        ..stop()
        ..stop(); // Second stop should not cause issues

      // Wait to collect values
      await Future<void>.delayed(
        const Duration(seconds: 2, milliseconds: 100),
      );

      await subscription.cancel();

      // All values should be 0 (timer was stopped immediately)
      final nonZeroValues = values.where((v) => v > 0).toList();
      expect(nonZeroValues, isEmpty);
    });

    test('should emit values every second', () async {
      final values = <int>[];
      final timestamps = <DateTime>[];
      
      final subscription = repository.timerStream.listen((value) {
        values.add(value);
        timestamps.add(DateTime.now());
      });

      repository.start();

      // Collect values for 3 seconds
      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 100));

      await subscription.cancel();

      // Check that emissions are approximately 1 second apart
      for (var i = 1; i < timestamps.length; i++) {
        final diff = timestamps[i].difference(timestamps[i - 1]);
        expect(diff.inMilliseconds, greaterThan(900));
        expect(diff.inMilliseconds, lessThan(1100));
      }
    });

    test('should properly clean up resources on dispose', () {
      final repository2 = CountUpTimerRepository();
      
      // Dispose should not throw
      expect(repository2.dispose, returnsNormally);
      
      // After dispose, the stream controller is closed
      // New subscriptions should complete immediately
      var completed = false;
      repository2.timerStream.listen(
        (_) {},
        onDone: () => completed = true,
      );
      
      // Give it a moment to complete
      Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
        expect(completed, isTrue);
      });
    });
  });
}
