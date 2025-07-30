import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockDestinations extends Mock implements Destinations {}

class MockHospital extends Mock implements Hospital {}

void main() {
  group('ActiveDestination', () {
    late MockDestinations mockDestination;
    late MockHospital mockHospitalInfo;

    setUp(() {
      mockDestination = MockDestinations();
      mockHospitalInfo = MockHospital();
    });

    test('should create with required parameters', () {
      final activeDestination = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      expect(activeDestination.destination, equals(mockDestination));
      expect(activeDestination.destinationInfo, equals(mockHospitalInfo));
    });

    test('should support value equality', () {
      final activeDestination1 = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      final activeDestination2 = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      expect(activeDestination1, equals(activeDestination2));
    });

    test('should have different equality for different destinations', () {
      final mockDestination2 = MockDestinations();

      final activeDestination1 = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      final activeDestination2 = ActiveDestination(
        destination: mockDestination2,
        destinationInfo: mockHospitalInfo,
      );

      expect(activeDestination1, isNot(equals(activeDestination2)));
    });

    test('should have different equality for different hospital info', () {
      final mockHospitalInfo2 = MockHospital();

      final activeDestination1 = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      final activeDestination2 = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo2,
      );

      expect(activeDestination1, isNot(equals(activeDestination2)));
    });

    test('should have correct props for Equatable', () {
      final activeDestination = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      expect(
        activeDestination.props,
        equals([mockDestination, mockHospitalInfo]),
      );
    });

    test('should have string representation', () {
      final activeDestination = ActiveDestination(
        destination: mockDestination,
        destinationInfo: mockHospitalInfo,
      );

      expect(activeDestination.toString(), contains('ActiveDestination'));
    });
  });
}
