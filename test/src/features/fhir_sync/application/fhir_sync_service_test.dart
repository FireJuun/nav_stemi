import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/application/patient_info_service.dart';
import 'package:nav_stemi/src/features/add_data/application/time_metrics_service.dart';
import 'package:nav_stemi/src/features/add_data/data/patient_info_repository.dart';
import 'package:nav_stemi/src/features/add_data/data/time_metrics_repository.dart';
import 'package:nav_stemi/src/features/fhir_sync/application/fhir_service.dart';
import 'package:nav_stemi/src/features/fhir_sync/application/fhir_sync_service.dart';
import 'package:nav_stemi/src/features/fhir_sync/data/fhir_sync_status.dart';

import '../../../../fixtures/patient_fixtures.dart';
import '../../../../fixtures/time_metrics_fixtures.dart';
import '../../../../helpers/test_helpers.dart';

class MockFhirService extends Mock implements FhirService {}

class MockPatientInfoSyncStatusRepository extends Mock
    implements PatientInfoSyncStatusRepository {}

class MockTimeMetricsSyncStatusRepository extends Mock
    implements TimeMetricsSyncStatusRepository {}

class MockPatientInfoService extends Mock implements PatientInfoService {}

class MockTimeMetricsService extends Mock implements TimeMetricsService {}

void main() {
  setUpAll(() {
    registerFallbackValue(FhirSyncStatus.offline);
  });
  group('FhirSyncService', () {
    late ProviderContainer container;
    late FhirSyncService syncService;
    late MockFhirService mockFhirService;
    late MockPatientInfoSyncStatusRepository mockPatientSyncStatus;
    late MockTimeMetricsSyncStatusRepository mockTimeMetricsSyncStatus;

    setUp(() {
      mockFhirService = MockFhirService();
      mockPatientSyncStatus = MockPatientInfoSyncStatusRepository();
      mockTimeMetricsSyncStatus = MockTimeMetricsSyncStatusRepository();

      // Set up default behavior
      when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
      when(() => mockPatientSyncStatus.setStatus(any(), any()))
          .thenReturn(null);
      when(() => mockTimeMetricsSyncStatus.setStatus(any(), any()))
          .thenReturn(null);

      container = createContainer(
        overrides: [
          fhirServiceProvider.overrideWithValue(mockFhirService),
          patientInfoSyncStatusRepositoryProvider
              .overrideWithValue(mockPatientSyncStatus),
          timeMetricsSyncStatusRepositoryProvider
              .overrideWithValue(mockTimeMetricsSyncStatus),
          // Override the model providers with test data
          patientInfoModelProvider.overrideWith((ref) {
            return Stream.value(testPatientInfo);
          }),
          timeMetricsModelProvider.overrideWith((ref) {
            return Stream.value(testTimeMetrics);
          }),
        ],
      );

      syncService = container.read(fhirSyncServiceProvider);
    });

    test('should initialize without errors', () {
      expect(syncService, isNotNull);
      expect(syncService.isSyncPaused, isFalse);
    });

    group('sync control', () {
      test('should pause syncing', () {
        syncService.pauseSyncing();
        expect(syncService.isSyncPaused, isTrue);
      });

      test('should resume syncing', () async {
        syncService.pauseSyncing();
        expect(syncService.isSyncPaused, isTrue);

        syncService.resumeSyncing();
        expect(syncService.isSyncPaused, isFalse);
      });

      test('should cancel patient info sync', () {
        // This should not throw
        syncService.cancelPatientInfoSync();
      });

      test('should cancel time metrics sync', () {
        // This should not throw
        syncService.cancelTimeMetricsSync();
      });
    });

    group('manual sync', () {
      test('should not sync when paused', () async {
        syncService.pauseSyncing();

        await syncService.manuallySyncAllData();

        verifyNever(() => mockFhirService.isConnected());
      });
    });
  });
}
