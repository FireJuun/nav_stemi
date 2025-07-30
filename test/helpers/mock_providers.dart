import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/add_data/data/patient_info_repository.dart';
import 'package:nav_stemi/src/features/add_data/data/time_metrics_repository.dart';
import 'package:nav_stemi/src/features/auth/data/auth_repository.dart';
import 'package:nav_stemi/src/features/auth/domain/app_user.dart';
import 'package:nav_stemi/src/features/fhir_sync/data/fhir_repository.dart';
import 'package:nav_stemi/src/features/navigate/data/hospitals_repository.dart';
import 'package:nav_stemi/src/features/preferences/data/shared_preferences_repository.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockPatientInfoRepository extends Mock implements PatientInfoRepository {}

class MockTimeMetricsRepository extends Mock implements TimeMetricsRepository {}

class MockFhirRepository extends Mock implements FhirRepository {}

class MockHospitalsRepository extends Mock implements HospitalsRepository {}

class MockSharedPreferencesRepository extends Mock
    implements SharedPreferencesRepository {}

class MockRef extends Mock implements Ref {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockHttpClient extends Mock implements http.Client {}

// Common test data
const testUserId = 'test-user-123';
const testUserEmail = 'test@example.com';

// Mock objects for AppUser instances
final mockGoogleSignInAccount = MockGoogleSignInAccount();
final mockAuthClient = MockAuthClient();
final mockHttpClient = MockHttpClient();

final testGoogleAppUser = GoogleAppUser(
  user: mockGoogleSignInAccount,
  client: mockAuthClient,
);

final testServiceAccountUser = ServiceAccountUser(
  email: testUserEmail,
  client: mockHttpClient,
);

// Provider overrides for testing
List<Override> createAuthOverrides(MockAuthRepository mockAuth) {
  return [
    authRepositoryProvider.overrideWithValue(mockAuth),
  ];
}

List<Override> createRepositoryOverrides({
  MockAuthRepository? authRepository,
  MockPatientInfoRepository? patientInfoRepository,
  MockTimeMetricsRepository? timeMetricsRepository,
  MockFhirRepository? fhirRepository,
  MockHospitalsRepository? hospitalsRepository,
  MockSharedPreferencesRepository? sharedPreferencesRepository,
}) {
  final overrides = <Override>[];

  if (authRepository != null) {
    overrides.add(authRepositoryProvider.overrideWithValue(authRepository));
  }

  if (patientInfoRepository != null) {
    overrides.add(
      patientInfoRepositoryProvider.overrideWithValue(patientInfoRepository),
    );
  }

  if (timeMetricsRepository != null) {
    overrides.add(
      timeMetricsRepositoryProvider.overrideWithValue(timeMetricsRepository),
    );
  }

  // Note: FhirRepository doesn't have a provider in the codebase
  // It's instantiated directly in services that use it

  if (hospitalsRepository != null) {
    overrides.add(
      hospitalsRepositoryProvider.overrideWithValue(hospitalsRepository),
    );
  }

  if (sharedPreferencesRepository != null) {
    overrides.add(
      sharedPreferencesRepositoryProvider
          .overrideWithValue(sharedPreferencesRepository),
    );
  }

  return overrides;
}
