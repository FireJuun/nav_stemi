import 'dart:async';

import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockRef extends Mock implements Ref {}

class MockPatientInfoSyncStatusRepository extends Mock
    implements PatientInfoSyncStatusRepository {}

class MockTimeMetricsSyncStatusRepository extends Mock
    implements TimeMetricsSyncStatusRepository {}

class MockFhirService extends Mock implements FhirService {}

class MockPatientInfoRepository extends Mock implements PatientInfoRepository {}

class MockTimeMetricsRepository extends Mock implements TimeMetricsRepository {}

class MockFhirResourceReferencesNotifier extends Mock
    implements FhirResourceReferencesNotifier {}

class MockRetryManager extends Mock implements RetryManager {}

class MockTimer extends Mock implements Timer {}

class MockProviderSubscription<T> extends Mock
    implements ProviderSubscription<T> {}

// Fake classes for fallback values
class FakeBundle extends Fake implements Bundle {}

class FakePatientInfoModel extends Fake implements PatientInfoModel {}

class FakeTimeMetricsModel extends Fake implements TimeMetricsModel {}

void main() {
  late FhirSyncService service;
  late MockRef mockRef;
  late MockPatientInfoSyncStatusRepository mockPatientInfoSyncStatusRepo;
  late MockTimeMetricsSyncStatusRepository mockTimeMetricsSyncStatusRepo;
  late MockFhirService mockFhirService;
  late MockPatientInfoRepository mockPatientInfoRepo;
  late MockTimeMetricsRepository mockTimeMetricsRepo;
  late MockFhirResourceReferencesNotifier mockFhirResourceReferencesNotifier;
  late StreamController<AsyncValue<PatientInfoModel?>>
      patientInfoStreamController;
  late StreamController<AsyncValue<TimeMetricsModel?>>
      timeMetricsStreamController;

  setUpAll(() {
    registerFallbackValue(FakeBundle());
    registerFallbackValue(FakePatientInfoModel());
    registerFallbackValue(FakeTimeMetricsModel());
    registerFallbackValue(FhirSyncStatus.synced);
  });

  setUp(() {
    mockRef = MockRef();
    mockPatientInfoSyncStatusRepo = MockPatientInfoSyncStatusRepository();
    mockTimeMetricsSyncStatusRepo = MockTimeMetricsSyncStatusRepository();
    mockFhirService = MockFhirService();
    mockPatientInfoRepo = MockPatientInfoRepository();
    mockTimeMetricsRepo = MockTimeMetricsRepository();
    mockFhirResourceReferencesNotifier = MockFhirResourceReferencesNotifier();

    patientInfoStreamController =
        StreamController<AsyncValue<PatientInfoModel?>>.broadcast();
    timeMetricsStreamController =
        StreamController<AsyncValue<TimeMetricsModel?>>.broadcast();

    // Setup default mock behaviors
    when(() => mockRef.read(patientInfoSyncStatusRepositoryProvider))
        .thenReturn(mockPatientInfoSyncStatusRepo);
    when(() => mockRef.read(timeMetricsSyncStatusRepositoryProvider))
        .thenReturn(mockTimeMetricsSyncStatusRepo);
    when(() => mockRef.read(fhirServiceProvider)).thenReturn(mockFhirService);
    when(() => mockRef.read(patientInfoRepositoryProvider))
        .thenReturn(mockPatientInfoRepo);
    when(() => mockRef.read(timeMetricsRepositoryProvider))
        .thenReturn(mockTimeMetricsRepo);
    when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
        .thenReturn(FhirResourceReferences());
    when(() => mockRef.read(fhirResourceReferencesNotifierProvider.notifier))
        .thenReturn(mockFhirResourceReferencesNotifier);

    when(
      () => mockPatientInfoSyncStatusRepo.setStatus(
        any(),
        any(),
      ),
    ).thenReturn(null);
    when(
      () => mockTimeMetricsSyncStatusRepo.setStatus(
        any(),
        any(),
      ),
    ).thenReturn(null);

    // Setup stream listeners
    when(
      () => mockRef.listen<AsyncValue<PatientInfoModel?>>(
        patientInfoModelProvider,
        any(),
      ),
    ).thenAnswer((invocation) {
      final listener = invocation.positionalArguments[1] as void Function(
        AsyncValue<PatientInfoModel?>?,
        AsyncValue<PatientInfoModel?>,
      );
      patientInfoStreamController.stream.listen((value) {
        listener(null, value);
      });
      return MockProviderSubscription<AsyncValue<PatientInfoModel?>>();
    });

    when(
      () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
        timeMetricsModelProvider,
        any(),
      ),
    ).thenAnswer((invocation) {
      final listener = invocation.positionalArguments[1] as void Function(
        AsyncValue<TimeMetricsModel?>?,
        AsyncValue<TimeMetricsModel?>,
      );
      timeMetricsStreamController.stream.listen((value) {
        listener(null, value);
      });
      return MockProviderSubscription<AsyncValue<TimeMetricsModel?>>();
    });

    // Setup default async values
    when(() => mockRef.read(patientInfoModelProvider))
        .thenReturn(const AsyncValue.data(null));
    when(() => mockRef.read(timeMetricsModelProvider))
        .thenReturn(const AsyncValue.data(null));

    service = FhirSyncService(mockRef);
  });

  tearDown(() {
    patientInfoStreamController.close();
    timeMetricsStreamController.close();
  });

  group('FhirSyncService', () {
    group('initialization', () {
      test('should setup listeners on creation', () {
        verify(
          () => mockRef.listen<AsyncValue<PatientInfoModel?>>(
            patientInfoModelProvider,
            any(),
          ),
        ).called(1);
        verify(
          () => mockRef.listen<AsyncValue<TimeMetricsModel?>>(
            timeMetricsModelProvider,
            any(),
          ),
        ).called(1);
      });

      test('should sync patient info when dirty', () async {
        const dirtyPatientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        patientInfoStreamController
            .add(const AsyncValue.data(dirtyPatientInfo));

        await Future.delayed(const Duration(milliseconds: 100));

        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.dirty,
          ),
        ).called(1);
      });

      test('should sync time metrics when dirty', () async {
        final dirtyTimeMetrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
        );

        // Setup required refs for time metrics sync
        when(() => mockRef.read(patientInfoModelProvider)).thenReturn(
          const AsyncValue.data(
            PatientInfoModel(
              firstName: 'John',
              lastName: 'Doe',
            ),
          ),
        );
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences(patientId: '123'));

        timeMetricsStreamController.add(AsyncValue.data(dirtyTimeMetrics));

        await Future.delayed(const Duration(milliseconds: 100));

        verify(
          () => mockTimeMetricsSyncStatusRepo.setStatus(
            FhirSyncStatus.dirty,
          ),
        ).called(1);
      });
    });

    group('sync control methods', () {
      test('cancelPatientInfoSync should cancel pending operations', () {
        service.cancelPatientInfoSync();
        // This test verifies the method runs without error
        expect(() => service.cancelPatientInfoSync(), returnsNormally);
      });

      test('cancelTimeMetricsSync should cancel pending operations', () {
        service.cancelTimeMetricsSync();
        // This test verifies the method runs without error
        expect(() => service.cancelTimeMetricsSync(), returnsNormally);
      });

      test('pauseSyncing should pause all sync operations', () {
        service.pauseSyncing();
        expect(service.isSyncPaused, isTrue);
      });

      test('resumeSyncing should resume sync operations', () async {
        service.pauseSyncing();
        expect(service.isSyncPaused, isTrue);

        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);

        service.resumeSyncing();
        expect(service.isSyncPaused, isFalse);
      });
    });

    group('manuallySyncAllData', () {
      test('should not sync when paused', () async {
        service.pauseSyncing();
        await service.manuallySyncAllData();

        verifyNever(() => mockFhirService.isConnected());
      });

      test('should sync patient info and time metrics when available',
          () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );
        final timeMetrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockRef.read(timeMetricsModelProvider))
            .thenReturn(AsyncValue.data(timeMetrics));
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('201 Created'),
                  location: FhirUri('Patient/123'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockPatientInfoRepo.updatePatientInfoModel(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);
        when(
          () => mockTimeMetricsRepo.setTimeMetrics(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);

        await service.manuallySyncAllData();

        verify(() => mockFhirService.isConnected()).called(greaterThan(0));
      });
    });

    group('sendFhirBundle', () {
      test('should send bundle successfully', () async {
        const bundle = Bundle(type: BundleType.transaction);
        const responseBundle = Bundle(type: BundleType.transactionResponse);

        when(() => mockFhirService.postTransactionBundleWithFallback(bundle))
            .thenAnswer((_) async => responseBundle);

        final result = await service.sendFhirBundle(bundle);

        expect(result, equals(responseBundle));
        verify(() => mockFhirService.postTransactionBundleWithFallback(bundle))
            .called(1);
      });

      test('should rethrow exceptions', () async {
        const bundle = Bundle(type: BundleType.transaction);
        final exception = Exception('Network error');

        when(() => mockFhirService.postTransactionBundleWithFallback(bundle))
            .thenThrow(exception);

        expect(
          () => service.sendFhirBundle(bundle),
          throwsA(equals(exception)),
        );
      });
    });

    group('patient info sync', () {
      test('should handle successful patient info sync', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('201 Created'),
                  location: FhirUri('Patient/123'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockPatientInfoRepo.updatePatientInfoModel(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.syncing,
          ),
        ).called(1);
        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.synced,
          ),
        ).called(1);
      });

      test('should handle offline state', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockFhirService.isConnected())
            .thenAnswer((_) async => false);

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.offline,
          ),
        ).called(1);
      });

      test('should handle sync errors', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenThrow(Exception('Network error'));

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.error,
            any(),
          ),
        ).called(2); // Once for error, once for max retries
      });

      test('should skip sync when not dirty', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));

        // Trigger sync attempt
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait briefly
        await Future.delayed(const Duration(milliseconds: 100));

        verifyNever(() => mockFhirService.isConnected());
      });
    });

    group('time metrics sync', () {
      test('should handle successful time metrics sync', () async {
        final timeMetrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
        );
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
        );

        when(() => mockRef.read(timeMetricsModelProvider))
            .thenReturn(AsyncValue.data(timeMetrics));
        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(
          FhirResourceReferences(
            patientId: '123',
          ),
        );
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(
          () => mockFhirService.readResource(
            resourceType: 'Patient',
            id: '123',
          ),
        ).thenAnswer((_) async => Patient(id: FhirString('123')));
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('201 Created'),
                  location: FhirUri('Encounter/456'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockTimeMetricsRepo.setTimeMetrics(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);
        when(() => mockRef.invalidate(fhirResourceReferencesNotifierProvider))
            .thenReturn(null);

        // Trigger sync through stream
        timeMetricsStreamController.add(AsyncValue.data(timeMetrics));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockTimeMetricsSyncStatusRepo.setStatus(
            FhirSyncStatus.syncing,
          ),
        ).called(1);
        verify(
          () => mockTimeMetricsSyncStatusRepo.setStatus(
            FhirSyncStatus.synced,
          ),
        ).called(1);
      });

      test('should sync patient info first if no patient reference', () async {
        final timeMetrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
        );
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(timeMetricsModelProvider))
            .thenReturn(AsyncValue.data(timeMetrics));
        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences()); // No patient ID
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('201 Created'),
                  location: FhirUri('Patient/123'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockPatientInfoRepo.updatePatientInfoModel(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);
        when(() => mockRef.invalidate(fhirResourceReferencesNotifierProvider))
            .thenReturn(null);

        // Trigger sync through stream
        timeMetricsStreamController.add(AsyncValue.data(timeMetrics));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        // Should have synced patient info first
        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.syncing,
          ),
        ).called(greaterThan(0));
      });

      test('should handle missing patient info', () async {
        final timeMetrics = TimeMetricsModel(
          timeArrivedAtPatient: DateTime.now(),
        );

        when(() => mockRef.read(timeMetricsModelProvider))
            .thenReturn(AsyncValue.data(timeMetrics));
        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(null)); // No patient info
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);

        // Trigger sync through stream
        timeMetricsStreamController.add(AsyncValue.data(timeMetrics));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockTimeMetricsSyncStatusRepo.setStatus(
            FhirSyncStatus.error,
            any(),
          ),
        ).called(2); // Once for error, once for max retries
      });
    });

    group('retry mechanism', () {
      test('should schedule retry on sync failure', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenThrow(Exception('Network error'));

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce to trigger initial sync
        await Future.delayed(const Duration(seconds: 3));

        // Should have set error status at least once
        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.error,
            any(),
          ),
        ).called(greaterThan(0));

        // The sync should have been attempted
        verify(() => mockFhirService.isConnected()).called(1);
      });

      test('should not retry when sync is paused', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenThrow(Exception('Network error'));

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for initial attempt
        await Future.delayed(const Duration(seconds: 3));

        // Pause syncing
        service.pauseSyncing();

        // Wait for what would be retry time
        await Future.delayed(const Duration(seconds: 3));

        // Should only have attempted once (no retry after pause)
        verify(() => mockFhirService.isConnected()).called(1);
      });
    });

    group('resource retrieval methods', () {
      test('should handle practitioner with cardiologist', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          cardiologist: 'Dr. Smith',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(
          FhirResourceReferences(
            practitionerId: '789',
          ),
        );
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(
          () => mockFhirService.readResource(
            resourceType: 'Practitioner',
            id: '789',
          ),
        ).thenAnswer((_) async => Practitioner(id: FhirString('789')));
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('200 OK'),
                  location: FhirUri('Patient/123'),
                ),
              ),
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('200 OK'),
                  location: FhirUri('Practitioner/789'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockPatientInfoRepo.updatePatientInfoModel(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        verify(
          () => mockFhirService.readResource(
            resourceType: 'Practitioner',
            id: '789',
          ),
        ).called(1);
      });

      test('should handle resource retrieval errors with fallback', () async {
        const patientInfo = PatientInfoModel(
          firstName: 'John',
          lastName: 'Doe',
          isDirty: true,
        );

        when(() => mockRef.read(patientInfoModelProvider))
            .thenReturn(const AsyncValue.data(patientInfo));
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(
          FhirResourceReferences(
            patientId: '123',
          ),
        );
        when(() => mockFhirService.isConnected()).thenAnswer((_) async => true);
        when(
          () => mockFhirService.readResource(
            resourceType: 'Patient',
            id: '123',
          ),
        ).thenThrow(Exception('Not found'));
        when(() => mockFhirService.postTransactionBundleWithFallback(any()))
            .thenAnswer(
          (_) async => Bundle(
            type: BundleType.transactionResponse,
            entry: [
              BundleEntry(
                response: BundleResponse(
                  status: FhirString('200 OK'),
                  location: FhirUri('Patient/123'),
                ),
              ),
            ],
          ),
        );
        when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
            .thenReturn(null);
        when(
          () => mockPatientInfoRepo.updatePatientInfoModel(
            any(),
            markAsDirty: any(named: 'markAsDirty'),
          ),
        ).thenReturn(null);

        // Trigger sync through stream
        patientInfoStreamController.add(const AsyncValue.data(patientInfo));

        // Wait for debounce and async operations
        await Future.delayed(const Duration(seconds: 3));

        // Should still complete sync despite resource retrieval error
        verify(
          () => mockPatientInfoSyncStatusRepo.setStatus(
            FhirSyncStatus.synced,
          ),
        ).called(1);
      });
    });
  });
}
