import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/add_data/data/time_metrics_repository.dart';
import 'package:nav_stemi/src/features/add_data/domain/time_metrics_model.dart';

import '../../../../fixtures/time_metrics_fixtures.dart';

void main() {
  group('TimeMetricsRepository', () {
    late TimeMetricsRepository repository;

    setUp(() {
      repository = TimeMetricsRepository();
    });

    test('should initialize with null', () {
      expect(repository.getTimeMetrics(), isNull);
    });

    test('should set time metrics', () {
      repository.setTimeMetrics(testTimeMetrics);

      final retrieved = repository.getTimeMetrics();
      expect(
        retrieved?.timeArrivedAtPatient,
        equals(testTimeMetrics.timeArrivedAtPatient),
      );
      expect(
        retrieved?.wasStemiActivated,
        equals(testTimeMetrics.wasStemiActivated),
      );
      expect(
        retrieved?.timeOfEkgs.length,
        equals(testTimeMetrics.timeOfEkgs.length),
      );
    });

    test('should clear time metrics', () {
      repository.setTimeMetrics(testTimeMetrics);
      expect(repository.getTimeMetrics(), isNotNull);

      repository.clearTimeMetrics();
      expect(repository.getTimeMetrics(), isNull);
    });

    test('should watch time metrics changes', () async {
      final stream = repository.watchTimeMetrics();

      // Collect stream events
      final events = <TimeMetricsModel?>[];
      final subscription = stream.listen(events.add);

      // Make changes
      repository.setTimeMetrics(testTimeMetrics);
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedMetrics = testTimeMetrics.copyWith(
        wasAspirinGiven: () => false,
      );
      repository.setTimeMetrics(updatedMetrics);
      await Future.delayed(const Duration(milliseconds: 100));

      repository.clearTimeMetrics();
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify events
      expect(events.length, greaterThanOrEqualTo(3));
      expect(events.first, isNull);
      expect(events.any((e) => e?.wasStemiActivated == true), isTrue);
      expect(events.any((e) => e?.wasAspirinGiven == false), isTrue);
      expect(events.last, isNull);

      await subscription.cancel();
    });

    test('should update complex time metrics correctly', () {
      final complexMetrics = TimeMetricsModel(
        timeArrivedAtPatient: DateTime(2024, 1, 1, 10),
        timeOfEkgs: {
          DateTime(2024, 1, 1, 10, 5),
          DateTime(2024, 1, 1, 10, 8),
          DateTime(2024, 1, 1, 10, 12),
        },
        timeOfStemiActivationDecision: DateTime(2024, 1, 1, 10, 10),
        wasStemiActivated: true,
        timeUnitLeftScene: DateTime(2024, 1, 1, 10, 15),
        timeOfAspirinGivenDecision: DateTime(2024, 1, 1, 10, 7),
        wasAspirinGiven: true,
        timeCathLabNotifiedDecision: DateTime(2024, 1, 1, 10, 11),
        wasCathLabNotified: true,
        timePatientArrivedAtDestination: DateTime(2024, 1, 1, 11),
        lockTimeArrivedAtPatient: true,
        lockTimeOfStemiActivationDecision: true,
        lockTimeOfAspirinGivenDecision: true,
        lockTimePatientArrivedAtDestination: true,
        isDirty: false,
      );

      repository.setTimeMetrics(complexMetrics);
      final retrieved = repository.getTimeMetrics();

      expect(retrieved?.timeOfEkgs.length, equals(3));
      expect(retrieved?.lockTimeArrivedAtPatient, isTrue);
      expect(retrieved?.lockTimeOfEkgs, isFalse);

      expect(retrieved?.wasStemiActivated, isTrue);
      expect(retrieved?.wasAspirinGiven, isTrue);
      expect(retrieved?.wasCathLabNotified, isTrue);
    });

    test('should handle rapid updates correctly', () async {
      // Perform multiple rapid updates
      for (var i = 0; i < 5; i++) {
        final metrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime(2024, 1, 1, 10, i),
          wasStemiActivated: i % 2 == 0,
        );
        repository.setTimeMetrics(metrics);
      }

      final finalMetrics = repository.getTimeMetrics();
      expect(
        finalMetrics?.timeArrivedAtPatient,
        equals(DateTime(2024, 1, 1, 10, 4)),
      );
      expect(finalMetrics?.wasStemiActivated, isTrue);
    });
  });
}
