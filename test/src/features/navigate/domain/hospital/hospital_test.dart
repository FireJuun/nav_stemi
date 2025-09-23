import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('Hospital', () {
    const testHospital = Hospital(
      facilityBrandedName: 'Test Hospital',
      facilityAddress: '123 Test St',
      facilityCity: 'Test City',
      facilityState: 'TC',
      facilityZip: 12345,
      latitude: 37.7749,
      longitude: -122.4194,
      county: 'Test County',
      source: 'Test Source',
      facilityPhone1: '555-123-4567',
      facilityPhone1Note: 'Main',
      facilityPhone2: '555-123-4568',
      facilityPhone2Note: 'ER',
      facilityPhone3: '555-123-4569',
      facilityPhone3Note: 'Cardiology',
      distanceToAsheboro: 25.5,
      pciCenter: 1,
    );

    test('should create Hospital with all required fields', () {
      expect(testHospital.facilityBrandedName, equals('Test Hospital'));
      expect(testHospital.facilityAddress, equals('123 Test St'));
      expect(testHospital.facilityCity, equals('Test City'));
      expect(testHospital.facilityState, equals('TC'));
      expect(testHospital.facilityZip, equals(12345));
      expect(testHospital.latitude, equals(37.7749));
      expect(testHospital.longitude, equals(-122.4194));
      expect(testHospital.county, equals('Test County'));
      expect(testHospital.source, equals('Test Source'));
      expect(testHospital.facilityPhone1, equals('555-123-4567'));
      expect(testHospital.facilityPhone1Note, equals('Main'));
      expect(testHospital.facilityPhone2, equals('555-123-4568'));
      expect(testHospital.facilityPhone2Note, equals('ER'));
      expect(testHospital.facilityPhone3, equals('555-123-4569'));
      expect(testHospital.facilityPhone3Note, equals('Cardiology'));
      expect(testHospital.distanceToAsheboro, equals(25.5));
      expect(testHospital.pciCenter, equals(1));
    });

    test('should support value equality', () {
      const hospital1 = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      const hospital2 = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      expect(hospital1, equals(hospital2));
    });

    test('should not be equal when fields differ', () {
      const hospital1 = Hospital(
        facilityBrandedName: 'Test Hospital',
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      const hospital2 = Hospital(
        facilityBrandedName: 'Different Hospital',  // Different name
        facilityAddress: '123 Test St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      expect(hospital1, isNot(equals(hospital2)));
    });

    test('should handle PCI center flag with isPci() helper', () {
      const pciHospital = Hospital(
        facilityBrandedName: 'PCI Hospital',
        facilityAddress: '123 PCI St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      const nonPciHospital = Hospital(
        facilityBrandedName: 'Non-PCI Hospital',
        facilityAddress: '123 Regular St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 0,
      );

      expect(pciHospital.isPci(), isTrue);
      expect(nonPciHospital.isPci(), isFalse);
    });

    test('should throw exception for invalid PCI center values', () {
      const invalidPciHospital = Hospital(
        facilityBrandedName: 'Invalid PCI Hospital',
        facilityAddress: '123 Invalid St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 2, // Invalid value
      );

      expect(
        () => invalidPciHospital.isPci(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid PCI center value: 2'),
          ),
        ),
      );
    });

    test('should handle location() helper method', () {
      const hospital = Hospital(
        facilityBrandedName: 'Location Test Hospital',
        facilityAddress: '123 Location St',
        facilityCity: 'Test City',
        facilityState: 'TC',
        facilityZip: 12345,
        latitude: 37.7749,
        longitude: -122.4194,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-123-4567',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      final waypoint = hospital.location();
      expect(waypoint.latitude, equals(37.7749));
      expect(waypoint.longitude, equals(-122.4194));
      expect(waypoint, isA<AppWaypoint>());
    });

    test('should create a valid string representation', () {
      final stringRep = testHospital.toString();
      expect(stringRep, contains('Hospital'));
      expect(stringRep, contains('Test Hospital'));
      expect(stringRep, contains('123 Test St'));
    });

    test('should handle copyWith correctly', () {
      final updatedHospital = testHospital.copyWith(
        facilityBrandedName: 'Updated Hospital Name',
        pciCenter: 0,
      );

      expect(
        updatedHospital.facilityBrandedName,
        equals('Updated Hospital Name'),
      );
      expect(
        updatedHospital.facilityAddress,
        equals(testHospital.facilityAddress),
      );
      expect(
        updatedHospital.facilityCity,
        equals(testHospital.facilityCity),
      );
      expect(
        updatedHospital.facilityState,
        equals(testHospital.facilityState),
      );
      expect(updatedHospital.facilityZip, equals(testHospital.facilityZip));
      expect(updatedHospital.latitude, equals(testHospital.latitude));
      expect(updatedHospital.longitude, equals(testHospital.longitude));
      expect(updatedHospital.pciCenter, equals(0));
      expect(
        updatedHospital.facilityPhone2,
        equals(testHospital.facilityPhone2),
      );
    });

    test('should handle null values in copyWith', () {
      final sameHospital = testHospital.copyWith();

      expect(
        sameHospital.facilityBrandedName,
        equals(testHospital.facilityBrandedName),
      );
      expect(
        sameHospital.facilityAddress,
        equals(testHospital.facilityAddress),
      );
      expect(sameHospital.facilityCity, equals(testHospital.facilityCity));
      expect(
        sameHospital.facilityState,
        equals(testHospital.facilityState),
      );
      expect(sameHospital.facilityZip, equals(testHospital.facilityZip));
      expect(sameHospital.latitude, equals(testHospital.latitude));
      expect(sameHospital.longitude, equals(testHospital.longitude));
      expect(sameHospital.pciCenter, equals(testHospital.pciCenter));
    });

    test('should serialize to and from JSON correctly', () {
      final json = testHospital.toJson();
      final fromJson = Hospital.fromJson(json);

      expect(fromJson, equals(testHospital));
    });

    test('should serialize to and from Map correctly', () {
      final map = testHospital.toMap();
      expect(map['facilityBrandedName'], equals('Test Hospital'));
      expect(map['facilityAddress'], equals('123 Test St'));
      expect(map['facilityCity'], equals('Test City'));
      expect(map['facilityState'], equals('TC'));
      expect(map['facilityZip'], equals(12345));
      expect(map['latitude'], equals(37.7749));
      expect(map['longitude'], equals(-122.4194));
      expect(map['pciCenter'], equals(1));

      final fromMap = Hospital.fromMap(map);
      expect(fromMap, equals(testHospital));
    });

    test('should handle optional phone fields correctly', () {
      const hospitalMinimal = Hospital(
        facilityBrandedName: 'Minimal Hospital',
        facilityAddress: '456 Minimal St',
        facilityCity: 'Minimal City',
        facilityState: 'MC',
        facilityZip: 54321,
        latitude: 40.7128,
        longitude: -74.0060,
        county: 'Minimal County',
        source: 'Minimal Source',
        facilityPhone1: '555-987-6543',
        distanceToAsheboro: 10,
        pciCenter: 0,
      );

      expect(hospitalMinimal.facilityPhone1Note, isNull);
      expect(hospitalMinimal.facilityPhone2, isNull);
      expect(hospitalMinimal.facilityPhone2Note, isNull);
      expect(hospitalMinimal.facilityPhone3, isNull);
      expect(hospitalMinimal.facilityPhone3Note, isNull);
    });
  });
}
