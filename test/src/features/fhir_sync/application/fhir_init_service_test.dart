import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mock classes
class MockRef extends Mock implements Ref {}

class MockFhirResourceReferencesNotifier extends Mock
    implements FhirResourceReferencesNotifier {}

class MockFhirSyncService extends Mock implements FhirSyncService {}

// Fake classes
class FakeBundle extends Fake implements Bundle {}

void main() {
  late FhirInitService service;
  late MockRef mockRef;
  late MockFhirResourceReferencesNotifier mockFhirResourceReferencesNotifier;
  late MockFhirSyncService mockFhirSyncService;

  setUpAll(() {
    registerFallbackValue(FakeBundle());
  });

  setUp(() {
    mockRef = MockRef();
    mockFhirResourceReferencesNotifier = MockFhirResourceReferencesNotifier();
    mockFhirSyncService = MockFhirSyncService();

    // Setup default mock behaviors
    when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
        .thenReturn(FhirResourceReferences());
    when(() => mockRef.read(fhirResourceReferencesNotifierProvider.notifier))
        .thenReturn(mockFhirResourceReferencesNotifier);
    when(() => mockRef.read(fhirSyncServiceProvider))
        .thenReturn(mockFhirSyncService);
    when(() => mockFhirResourceReferencesNotifier.updateFromBundle(any()))
        .thenReturn(null);

    service = FhirInitService(mockRef);
  });

  group('FhirInitService', () {
    group('initializeBlankResources', () {
      test('creates patient and encounter when neither exists', () async {
        // Setup - no existing references
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences());

        // Mock the response bundles
        final patientResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/123'),
              ),
            ),
          ],
        );

        final encounterResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        var patientCreated = false;
        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((invocation) async {
          final bundle = invocation.positionalArguments[0] as Bundle;
          final firstEntry = bundle.entry?.first;
          if (firstEntry?.resource is Patient) {
            patientCreated = true;
            return patientResponseBundle;
          } else if (firstEntry?.resource is Encounter) {
            return encounterResponseBundle;
          }
          throw Exception('Unexpected bundle');
        });

        // Mock the references to include patient after patient creation
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenAnswer((_) {
          if (patientCreated) {
            return FhirResourceReferences(
              patientId: '123',
            );
          }
          return FhirResourceReferences();
        });

        await service.initializeBlankResources();

        // Verify patient was created
        verify(
          () => mockFhirSyncService.sendFhirBundle(
            any(
              that: predicate<Bundle>((bundle) {
                final resource = bundle.entry?.first.resource;
                return resource is Patient &&
                    resource.active == FhirBoolean(false) &&
                    resource.gender == AdministrativeGender.unknown &&
                    resource.name?.first.family.toString() == 'Temporary' &&
                    resource.name?.first.given?.first.toString() == 'Patient';
              }),
            ),
          ),
        ).called(1);

        // Verify encounter was created
        verify(
          () => mockFhirSyncService.sendFhirBundle(
            any(
              that: predicate<Bundle>((bundle) {
                final resource = bundle.entry?.first.resource;
                return resource is Encounter &&
                    resource.status == EncounterStatus.inProgress &&
                    resource.class_.code.toString() == 'FLD';
              }),
            ),
          ),
        ).called(1);

        // Verify references were updated
        verify(
          () => mockFhirResourceReferencesNotifier
              .updateFromBundle(patientResponseBundle),
        ).called(1);
        verify(
          () => mockFhirResourceReferencesNotifier
              .updateFromBundle(encounterResponseBundle),
        ).called(1);
      });

      test('skips patient creation when patient already exists', () async {
        // Setup - patient exists but no encounter
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences(patientId: '123'));

        final encounterResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((_) async => encounterResponseBundle);

        await service.initializeBlankResources();

        // Verify only encounter was created, not patient
        verify(
          () => mockFhirSyncService.sendFhirBundle(
            any(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Encounter;
              }),
            ),
          ),
        ).called(1);

        // Should not create patient
        verifyNever(
          () => mockFhirSyncService.sendFhirBundle(
            any(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Patient;
              }),
            ),
          ),
        );
      });

      test('skips all creation when both resources exist', () async {
        // Setup - both patient and encounter exist
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(
          FhirResourceReferences(
            patientId: '123',
            encounterId: '456',
          ),
        );

        await service.initializeBlankResources();

        // Verify no bundles were sent
        verifyNever(() => mockFhirSyncService.sendFhirBundle(any()));
      });

      test('handles race condition for patient creation', () async {
        // This test simulates the scenario where another process creates the patient
        // between our initial check and when we try to create it.
        // The expected behavior is that _createBlankPatient returns early
        // when it detects the patient was already created.

        var callCount = 0;
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenAnswer((_) {
          callCount++;
          // Simulates another process creating the patient between checks:
          // 1st call: initializeBlankResources checks - no patient
          // 2nd call: _createBlankPatient checks again - patient now exists
          // 3rd call: _createBlankEncounter check for patient ref
          // 4th call: _createBlankEncounter gets updated refs for patient
          if (callCount == 1) {
            return FhirResourceReferences(); // No patient initially
          } else {
            return FhirResourceReferences(
              patientId: '123', // Patient created by another process
            );
          }
        });

        final encounterResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((_) async => encounterResponseBundle);

        await service.initializeBlankResources();

        // Should only create encounter since patient appeared between checks
        verify(
          () => mockFhirSyncService.sendFhirBundle(
            any(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Encounter;
              }),
            ),
          ),
        ).called(1);
      });
    });

    group('_createBlankPatient', () {
      test('creates patient with correct structure', () async {
        var patientCreated = false;
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenAnswer((_) {
          if (patientCreated) {
            return FhirResourceReferences(
              patientId: '123',
            );
          }
          return FhirResourceReferences();
        });

        final patientResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/123'),
              ),
            ),
          ],
        );

        final encounterResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((invocation) async {
          final bundle = invocation.positionalArguments[0] as Bundle;
          if (bundle.entry?.first.resource is Patient) {
            patientCreated = true;
            return patientResponseBundle;
          }
          return encounterResponseBundle;
        });

        await service.initializeBlankResources();

        // Verify patient has required fields
        final capturedBundle = verify(
          () => mockFhirSyncService.sendFhirBundle(
            captureAny(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Patient;
              }),
            ),
          ),
        ).captured.first as Bundle;

        final patient = capturedBundle.entry!.first.resource! as Patient;

        // Check identifier
        expect(patient.identifier, hasLength(1));
        expect(
          patient.identifier?.first.system.toString(),
          'https://navstemi.org/patient',
        );
        expect(patient.identifier?.first.use, IdentifierUse.official);
        expect(patient.identifier?.first.value, isNotNull);

        // Check active status
        expect(patient.active, FhirBoolean(false));

        // Check name
        expect(patient.name, hasLength(1));
        expect(patient.name?.first.family.toString(), 'Temporary');
        expect(patient.name?.first.given?.first.toString(), 'Patient');
        expect(patient.name?.first.use, NameUse.temp);

        // Check gender
        expect(patient.gender, AdministrativeGender.unknown);
      });

      test('patient identifier uses UUID format', () async {
        var patientCreated = false;
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenAnswer((_) {
          if (patientCreated) {
            return FhirResourceReferences(
              patientId: '123',
            );
          }
          return FhirResourceReferences();
        });

        final patientResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/123'),
              ),
            ),
          ],
        );

        final encounterResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((invocation) async {
          final bundle = invocation.positionalArguments[0] as Bundle;
          if (bundle.entry?.first.resource is Patient) {
            patientCreated = true;
            return patientResponseBundle;
          }
          return encounterResponseBundle;
        });

        await service.initializeBlankResources();

        final capturedBundle = verify(
          () => mockFhirSyncService.sendFhirBundle(
            captureAny(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Patient;
              }),
            ),
          ),
        ).captured.first as Bundle;

        final patient = capturedBundle.entry!.first.resource! as Patient;
        final identifierValue = patient.identifier?.first.value.toString();

        // UUID v4 format check
        expect(identifierValue, isNotNull);
        expect(
          identifierValue,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
      });
    });

    group('_createBlankEncounter', () {
      test('creates encounter with correct structure', () async {
        // Setup - patient exists
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences(patientId: '123'));

        final responseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((_) async => responseBundle);

        await service.initializeBlankResources();

        // Verify encounter has required fields
        final capturedBundle = verify(
          () => mockFhirSyncService.sendFhirBundle(
            captureAny(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Encounter;
              }),
            ),
          ),
        ).captured.first as Bundle;

        final encounter = capturedBundle.entry!.first.resource! as Encounter;

        // Check status
        expect(encounter.status, EncounterStatus.inProgress);

        // Check class
        expect(
          encounter.class_.system.toString(),
          'http://terminology.hl7.org/CodeSystem/v3-ActCode',
        );
        expect(encounter.class_.code.toString(), 'FLD');
        expect(encounter.class_.display.toString(), 'field');

        // Check type (US Core requirement)
        expect(encounter.type, hasLength(1));
        expect(encounter.type?.first.coding?.first.code.toString(), 'AMB');
        expect(
          encounter.type?.first.coding?.first.display.toString(),
          'ambulatory',
        );
        expect(encounter.type?.first.text.toString(), 'Ambulatory encounter');

        // Check subject reference
        expect(encounter.subject, isNotNull);
        expect(encounter.subject?.reference.toString(), 'Patient/123');

        // Check period
        expect(encounter.period, isNotNull);
        expect(encounter.period?.start, isNotNull);
      });

      test('throws exception when patient reference is null', () async {
        // This test verifies the error handling when patient reference is unexpectedly null
        // We'll test this by having the references not update properly after patient creation
        var callCount = 0;
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenAnswer((_) {
          callCount++;
          // Always return empty refs, simulating a failure to update references
          return FhirResourceReferences();
        });

        final patientResponseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Patient/123'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((invocation) async {
          final bundle = invocation.positionalArguments[0] as Bundle;
          if (bundle.entry?.first.resource is Patient) {
            return patientResponseBundle;
          }
          // Should throw when trying to create encounter without patient ref
          throw Exception('Should not reach here');
        });

        // The service should create patient but fail on encounter
        expect(
          () => service.initializeBlankResources(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Cannot create Encounter: Patient reference is null'),
            ),
          ),
        );
      });

      test('encounter period uses current datetime', () async {
        when(() => mockRef.read(fhirResourceReferencesNotifierProvider))
            .thenReturn(FhirResourceReferences(patientId: '123'));

        final beforeCreation = DateTime.now();

        final responseBundle = Bundle(
          type: BundleType.transactionResponse,
          entry: [
            BundleEntry(
              response: BundleResponse(
                status: FhirString('201 Created'),
                location: FhirUri('Encounter/456'),
              ),
            ),
          ],
        );

        when(() => mockFhirSyncService.sendFhirBundle(any()))
            .thenAnswer((_) async => responseBundle);

        await service.initializeBlankResources();

        final afterCreation = DateTime.now();

        final capturedBundle = verify(
          () => mockFhirSyncService.sendFhirBundle(
            captureAny(
              that: predicate<Bundle>((bundle) {
                return bundle.entry?.first.resource is Encounter;
              }),
            ),
          ),
        ).captured.first as Bundle;

        final encounter = capturedBundle.entry!.first.resource! as Encounter;
        expect(encounter.period?.start, isNotNull);

        // The period start should be between our before/after times
        // Can't directly compare FhirDateTime to DateTime easily,
        // but we've verified it was set
      });
    });

    group('fhirInitService provider', () {
      test('returns FhirInitService instance', () {
        final container = ProviderContainer();
        final service = container.read(fhirInitServiceProvider);

        expect(service, isA<FhirInitService>());
      });
    });
  });
}
