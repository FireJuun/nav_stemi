import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/time_metrics_service.dart';
import 'package:nav_stemi/src/features/add_data/data/time_metrics_repository.dart';
import 'package:nav_stemi/src/features/add_data/domain/time_metrics_model.dart';

import '../../../../fixtures/time_metrics_fixtures.dart';
import '../../../../helpers/mock_providers.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('TimeMetricsService', () {
    late ProviderContainer container;
    late TimeMetricsService service;
    late MockTimeMetricsRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(
        TimeMetricsModel(
          wasStemiActivated: false,
          timeArrivedAtPatient: DateTime.now(),
          timeUnitLeftScene: DateTime.now(),
          timePatientArrivedAtDestination: DateTime.now(),
        ),
      );
    });

    setUp(() {
      mockRepository = MockTimeMetricsRepository();

      // Set up default behavior
      when(() => mockRepository.getTimeMetrics()).thenReturn(testTimeMetrics);
      when(() => mockRepository.setTimeMetrics(any())).thenReturn(null);
      when(() => mockRepository.clearTimeMetrics()).thenReturn(null);

      container = createContainer(
        overrides: [
          timeMetricsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      service = container.read(timeMetricsServiceProvider);
    });

    test('should set time metrics', () {
      const newMetrics = TimeMetricsModel(
        wasStemiActivated: true,
      );

      service.setTimeMetrics(newMetrics);

      verify(() => mockRepository.setTimeMetrics(newMetrics)).called(1);
    });

    test('should clear time metrics', () {
      service.clearTimeMetrics();

      verify(() => mockRepository.clearTimeMetrics()).called(1);
    });

    group('time field setters', () {
      test('should set time arrived at patient', () {
        final newTime = DateTime(2024, 2, 1, 10);

        service.setTimeArrivedAtPatient(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeArrivedAtPatient, equals(newTime));
      });

      test('should toggle time arrived at patient lock', () {
        service.toggleTimeArrivedAtPatientLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeArrivedAtPatient,
          equals(!testTimeMetrics.lockTimeArrivedAtPatient),
        );
      });

      test('should set time unit left scene', () {
        final newTime = DateTime(2024, 2, 1, 10, 15);

        service.setTimeUnitLeftScene(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeUnitLeftScene, equals(newTime));
      });

      test('should toggle time unit left scene lock', () {
        service.toggleTimeUnitLeftSceneLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeUnitLeftScene,
          equals(!testTimeMetrics.lockTimeUnitLeftScene),
        );
      });

      test('should set time patient arrived at destination', () {
        final newTime = DateTime(2024, 2, 1, 11);

        service.setTimePatientArrivedAtDestination(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timePatientArrivedAtDestination, equals(newTime));
      });

      test('should toggle time patient arrived at destination lock', () {
        service.toggleTimePatientArrivedAtDestinationLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimePatientArrivedAtDestination,
          equals(!testTimeMetrics.lockTimePatientArrivedAtDestination),
        );
      });
    });

    group('EKG management', () {
      test('should set first EKG when no EKGs exist', () {
        when(() => mockRepository.getTimeMetrics()).thenReturn(
          const TimeMetricsModel(),
        );

        final newEkgTime = DateTime(2024, 2, 1, 10, 5);
        service.setTimeOfFirstEkg(newEkgTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeOfEkgs, contains(newEkgTime));
        expect(captured.timeOfEkgs.length, equals(1));
      });

      test('should update first EKG when EKGs exist', () {
        final newFirstEkg = DateTime(2021, 2, 1, 10, 3);
        service.setTimeOfFirstEkg(newFirstEkg);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        final sortedEkgs = captured.timeOfEkgs.toList()
          ..sort((a, b) => a!.compareTo(b!));
        expect(sortedEkgs.first, equals(newFirstEkg));
      });

      test('should add new EKG', () {
        final newEkg = DateTime(2024, 2, 1, 10, 20);
        service.addTimeOfEkg(newEkg);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeOfEkgs, contains(newEkg));
      });

      test('should remove EKG', () {
        final ekgToRemove = testTimeMetrics.timeOfEkgs.first!;
        service.removeTimeOfEkg(ekgToRemove);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeOfEkgs, isNot(contains(ekgToRemove)));
      });

      test('should toggle EKG lock', () {
        service.toggleTimeOfFirstEkgLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeOfEkgs,
          equals(!testTimeMetrics.lockTimeOfEkgs),
        );
      });
    });

    group('STEMI activation', () {
      test('should set STEMI activation decision time', () {
        final newTime = DateTime(2024, 2, 1, 10, 12);

        service.setTimeOfStemiActivationDecision(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeOfStemiActivationDecision, equals(newTime));
      });

      test('should set STEMI activated status', () {
        service.setWasStemiActivated(false);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.wasStemiActivated, isFalse);
      });

      test('should toggle STEMI activation decision lock', () {
        service.toggleTimeOfStemiActivationDecisionLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeOfStemiActivationDecision,
          equals(!testTimeMetrics.lockTimeOfStemiActivationDecision),
        );
      });
    });

    group('aspirin decision', () {
      test('should set aspirin given decision time', () {
        final newTime = DateTime(2024, 2, 1, 10, 8);

        service.setTimeOfAspirinGivenDecision(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeOfAspirinGivenDecision, equals(newTime));
      });

      test('should set aspirin given status', () {
        service.setWasAspirinGiven(false);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.wasAspirinGiven, isFalse);
      });

      test('should toggle aspirin given decision lock', () {
        service.toggleTimeOfAspirinGivenDecisionLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeOfAspirinGivenDecision,
          equals(!testTimeMetrics.lockTimeOfAspirinGivenDecision),
        );
      });
    });

    group('cath lab notification', () {
      test('should set cath lab notified decision time', () {
        final newTime = DateTime(2024, 2, 1, 10, 18);

        service.setTimeCathLabNotifiedDecision(newTime);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.timeCathLabNotifiedDecision, equals(newTime));
      });

      test('should set cath lab notified status', () {
        service.setWasCathLabNotified(false);

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(captured.wasCathLabNotified, isFalse);
      });

      test('should toggle cath lab notified decision lock', () {
        service.toggleTimeCathLabNotifiedDecisionLock();

        final captured = verify(
          () => mockRepository.setTimeMetrics(captureAny()),
        ).captured.single as TimeMetricsModel;

        expect(
          captured.lockTimeCathLabNotifiedDecision,
          equals(!testTimeMetrics.lockTimeCathLabNotifiedDecision),
        );
      });
    });
  });
}
