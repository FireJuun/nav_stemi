import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/time_metrics_service.dart';
import 'package:nav_stemi/src/features/add_data/presentation/checklist_controller.dart';

import '../../../../helpers/test_helpers.dart';

class MockTimeMetricsService extends Mock implements TimeMetricsService {}

void main() {
  group('ChecklistController', () {
    late ProviderContainer container;
    late MockTimeMetricsService mockService;

    setUp(() {
      mockService = MockTimeMetricsService();

      // Set up default behavior
      when(() => mockService.setWasAspirinGiven(any())).thenReturn(null);
      when(() => mockService.setWasCathLabNotified(any())).thenReturn(null);

      container = createContainer(
        overrides: [
          timeMetricsServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    test('should have initial state as AsyncValue.data(null)', () {
      final controller = container.read(checklistControllerProvider);
      expect(controller, equals(const AsyncValue<void>.data(null)));
    });

    group('aspirin checklist', () {
      test('should set aspirin given as true when checklist is true', () {
        container
            .read(checklistControllerProvider.notifier)
            .setDidGetAspirinFromChecklist(checklist: true);

        verify(() => mockService.setWasAspirinGiven(true)).called(1);
      });

      test('should set aspirin given as null when checklist is false', () {
        container
            .read(checklistControllerProvider.notifier)
            .setDidGetAspirinFromChecklist(checklist: false);

        // DTO converts checklist false to data null
        verify(() => mockService.setWasAspirinGiven(null)).called(1);
      });

      test('should set aspirin given as false when checklist is null', () {
        container
            .read(checklistControllerProvider.notifier)
            .setDidGetAspirinFromChecklist(checklist: null);

        // DTO converts checklist null to data false
        verify(() => mockService.setWasAspirinGiven(false)).called(1);
      });
    });

    group('cath lab notification checklist', () {
      test('should set cath lab notified as true when checklist is true', () {
        container
            .read(checklistControllerProvider.notifier)
            .setIsCathLabNotifiedFromChecklist(checklist: true);

        verify(() => mockService.setWasCathLabNotified(true)).called(1);
      });

      test('should set cath lab notified as null when checklist is false', () {
        container
            .read(checklistControllerProvider.notifier)
            .setIsCathLabNotifiedFromChecklist(checklist: false);

        // DTO converts checklist false to data null
        verify(() => mockService.setWasCathLabNotified(null)).called(1);
      });

      test('should set cath lab notified as false when checklist is null', () {
        container
            .read(checklistControllerProvider.notifier)
            .setIsCathLabNotifiedFromChecklist(checklist: null);

        // DTO converts checklist null to data false
        verify(() => mockService.setWasCathLabNotified(false)).called(1);
      });
    });
  });
}
