import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/fhir_sync/application/retry_manager.dart';

void main() {
  group('RetryManager', () {
    test('getNextRetryDelayMs calculates correct delay', () {
      final manager = RetryManager(
        initialBackoffMs: 100,
      );

      // Test initial delay (no retries yet)
      expect(manager.getNextRetryDelayMs('operation1'), 100);

      // Increment and test subsequent delays
      manager.incrementRetryCount('operation1');
      expect(manager.getNextRetryDelayMs('operation1'), 200);

      manager.incrementRetryCount('operation1');
      expect(manager.getNextRetryDelayMs('operation1'), 400);
    });

    test('getRetryCount returns correct count', () {
      final manager = RetryManager();

      // Test initial count
      expect(manager.getRetryCount('operation1'), 0);

      // Increment and test
      manager.incrementRetryCount('operation1');
      expect(manager.getRetryCount('operation1'), 1);

      manager.incrementRetryCount('operation1');
      expect(manager.getRetryCount('operation1'), 2);
    });
  });
}
