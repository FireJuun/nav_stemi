import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/time_metrics_service.dart';
import 'package:nav_stemi/src/features/add_data/domain/time_metrics_model.dart';
import 'package:nav_stemi/src/features/add_data/presentation/data_entry/time_metrics/time_metrics_controller.dart';

import '../../../../helpers/test_helpers.dart';

class MockTimeMetricsService extends Mock implements TimeMetricsService {}

class FakeTimeMetricsModel extends Fake implements TimeMetricsModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTimeMetricsModel());
  });

  group('TimeMetricsController', () {
    late ProviderContainer container;
    late MockTimeMetricsService mockService;

    setUp(() {
      mockService = MockTimeMetricsService();

      // Set up default behavior
      when(() => mockService.setTimeMetrics(any())).thenReturn(null);
      when(() => mockService.setTimeArrivedAtPatient(any())).thenReturn(null);
      when(() => mockService.toggleTimeArrivedAtPatientLock()).thenReturn(null);
      when(() => mockService.setTimeOfFirstEkg(any())).thenReturn(null);
      when(() => mockService.toggleTimeOfFirstEkgLock()).thenReturn(null);
      when(() => mockService.addTimeOfEkg(any())).thenReturn(null);
      when(() => mockService.removeTimeOfEkg(any())).thenReturn(null);
      when(() => mockService.setTimeOfStemiActivationDecision(any()))
          .thenReturn(null);
      when(() => mockService.setWasStemiActivated(any())).thenReturn(null);
      when(() => mockService.toggleTimeOfStemiActivationDecisionLock())
          .thenReturn(null);
      when(() => mockService.setTimeUnitLeftScene(any())).thenReturn(null);
      when(() => mockService.toggleTimeUnitLeftSceneLock()).thenReturn(null);
      when(() => mockService.setTimeOfAspirinGivenDecision(any()))
          .thenReturn(null);
      when(() => mockService.setWasAspirinGiven(any())).thenReturn(null);
      when(() => mockService.toggleTimeOfAspirinGivenDecisionLock())
          .thenReturn(null);
      when(() => mockService.setTimeCathLabNotifiedDecision(any()))
          .thenReturn(null);
      when(() => mockService.setWasCathLabNotified(any())).thenReturn(null);
      when(() => mockService.toggleTimeCathLabNotifiedDecisionLock())
          .thenReturn(null);
      when(() => mockService.setTimePatientArrivedAtDestination(any()))
          .thenReturn(null);
      when(() => mockService.toggleTimePatientArrivedAtDestinationLock())
          .thenReturn(null);
      when(() => mockService.clearTimeMetrics()).thenReturn(null);

      container = createContainer(
        overrides: [
          timeMetricsServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    test('should have initial state as AsyncValue.data(null)', () {
      final controller = container.read(timeMetricsControllerProvider);
      expect(controller, equals(const AsyncValue<void>.data(null)));
    });

    group('time field updates', () {
      test('should set time arrived at patient', () {
        final time = DateTime(2024, 1, 1, 10);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeArrivedAtPatient(time);

        verify(() => mockService.setTimeArrivedAtPatient(time)).called(1);
      });

      test('should toggle time arrived at patient lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeArrivedAtPatientLock();

        verify(() => mockService.toggleTimeArrivedAtPatientLock()).called(1);
      });

      test('should set time of first EKG', () {
        final time = DateTime(2024, 1, 1, 10, 5);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeOfFirstEkg(time);

        verify(() => mockService.setTimeOfFirstEkg(time)).called(1);
      });

      test('should toggle time of first EKG lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeOfFirstEkgLock();

        verify(() => mockService.toggleTimeOfFirstEkgLock()).called(1);
      });
    });

    group('STEMI activation', () {
      test('should set time of STEMI activation decision', () {
        final time = DateTime(2024, 1, 1, 10, 12);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeOfStemiActivationDecision(time);

        verify(() => mockService.setTimeOfStemiActivationDecision(time))
            .called(1);
      });

      test('should set was STEMI activated', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .setWasStemiActivated(true);

        verify(() => mockService.setWasStemiActivated(true)).called(1);
      });

      test('should toggle STEMI activation decision lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeOfStemiActivationDecisionLock();

        verify(() => mockService.toggleTimeOfStemiActivationDecisionLock())
            .called(1);
      });
    });

    group('aspirin decision', () {
      test('should set time of aspirin given decision', () {
        final time = DateTime(2024, 1, 1, 10, 8);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeOfAspirinGivenDecision(time);

        verify(() => mockService.setTimeOfAspirinGivenDecision(time)).called(1);
      });

      test('should set was aspirin given', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .setWasAspirinGiven(true);

        verify(() => mockService.setWasAspirinGiven(true)).called(1);
      });

      test('should toggle aspirin given decision lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeOfAspirinGivenDecisionLock();

        verify(() => mockService.toggleTimeOfAspirinGivenDecisionLock())
            .called(1);
      });
    });

    group('cath lab notification', () {
      test('should set time cath lab notified decision', () {
        final time = DateTime(2024, 1, 1, 10, 18);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeCathLabNotifiedDecision(time);

        verify(() => mockService.setTimeCathLabNotifiedDecision(time))
            .called(1);
      });

      test('should set was cath lab notified', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .setWasCathLabNotified(true);

        verify(() => mockService.setWasCathLabNotified(true)).called(1);
      });

      test('should toggle cath lab notified decision lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeCathLabNotifiedDecisionLock();

        verify(() => mockService.toggleTimeCathLabNotifiedDecisionLock())
            .called(1);
      });
    });

    group('other time fields', () {
      test('should set time unit left scene', () {
        final time = DateTime(2024, 1, 1, 10, 15);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimeUnitLeftScene(time);

        verify(() => mockService.setTimeUnitLeftScene(time)).called(1);
      });

      test('should toggle time unit left scene lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimeUnitLeftSceneLock();

        verify(() => mockService.toggleTimeUnitLeftSceneLock()).called(1);
      });

      test('should set time patient arrived at destination', () {
        final time = DateTime(2024, 1, 1, 11);
        container
            .read(timeMetricsControllerProvider.notifier)
            .setTimePatientArrivedAtDestination(time);

        verify(() => mockService.setTimePatientArrivedAtDestination(time))
            .called(1);
      });

      test('should toggle time patient arrived at destination lock', () {
        container
            .read(timeMetricsControllerProvider.notifier)
            .toggleTimePatientArrivedAtDestinationLock();

        verify(() => mockService.toggleTimePatientArrivedAtDestinationLock())
            .called(1);
      });
    });

    test('should clear time metrics', () {
      container.read(timeMetricsControllerProvider.notifier).clearTimeMetrics();

      verify(() => mockService.clearTimeMetrics()).called(1);
    });
  });
}
