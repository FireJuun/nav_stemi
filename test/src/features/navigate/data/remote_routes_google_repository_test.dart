import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockHospital extends Mock implements Hospital {}

void main() {
  late RemoteRoutesGoogleRepository repository;
  late AppWaypoint testOrigin;

  setUp(() {
    repository = RemoteRoutesGoogleRepository();
    testOrigin = const AppWaypoint(
      latitude: 35,
      longitude: -80,
      label: 'Origin',
    );
  });

  group('RemoteRoutesGoogleRepository', () {
    test('should throw assertion error for empty hospital list', () {
      expect(
        () => repository.getDistanceInfoFromHospitalList(
          origin: testOrigin,
          hospitalListAndDistances: {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw assertion error for more than 10 hospitals', () {
      final hospitalList = <Hospital, double>{};
      for (var i = 0; i < 11; i++) {
        final mockHospital = MockHospital();
        when(mockHospital.location).thenReturn(
          AppWaypoint(
            latitude: 35.0 + i * 0.1,
            longitude: -80.0 + i * 0.1,
            label: 'Hospital $i',
          ),
        );
        hospitalList[mockHospital] = i * 1.0;
      }

      expect(
        () => repository.getDistanceInfoFromHospitalList(
          origin: testOrigin,
          hospitalListAndDistances: hospitalList,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should handle toGoogleRoutes extension correctly', () {
      final waypoint = testOrigin.toGoogleRoutes();
      expect(waypoint.latitude, equals(testOrigin.latitude));
      expect(waypoint.longitude, equals(testOrigin.longitude));
    });

    test('should be a RemoteRoutesRepository', () {
      expect(repository, isA<RemoteRoutesRepository>());
    });
  });
}
