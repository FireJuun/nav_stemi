import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('ActiveDestinationRepository', () {
    late ActiveDestinationRepository repository;
    late Hospital testHospital;
    late ActiveDestination testDestination;

    setUp(() {
      repository = ActiveDestinationRepository();
      
      testHospital = const Hospital(
        facilityBrandedName: 'Test Medical Center',
        facilityAddress: '123 Main St',
        facilityCity: 'Test City',
        facilityState: 'TS',
        facilityZip: 12345,
        latitude: 35.7796,
        longitude: -78.6382,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-0100',
        distanceToAsheboro: 15.5,
        pciCenter: 1,
      );

      testDestination = ActiveDestination(
        destination: null, // Google Navigation SDK object not needed for tests
        destinationInfo: testHospital,
      );
    });

    test('should initialize with null active destination', () {
      expect(repository.activeDestination, isNull);
    });

    test('should set and get active destination', () {
      repository.activeDestination = testDestination;
      
      expect(repository.activeDestination, equals(testDestination));
      expect(
        repository.activeDestination?.destinationInfo,
        equals(testHospital),
      );
    });

    test('should update active destination', () {
      final updatedHospital = testHospital.copyWith(
        facilityBrandedName: 'Updated Medical Center',
        pciCenter: 0,
      );
      
      final updatedDestination = ActiveDestination(
        destination: null,
        destinationInfo: updatedHospital,
      );

      repository.activeDestination = testDestination;
      expect(repository.activeDestination, equals(testDestination));

      repository.activeDestination = updatedDestination;
      expect(repository.activeDestination, equals(updatedDestination));
      expect(
        repository.activeDestination?.destinationInfo.facilityBrandedName,
        equals('Updated Medical Center'),
      );
    });

    test('should clear active destination by setting to null', () {
      repository.activeDestination = testDestination;
      expect(repository.activeDestination, isNotNull);

      repository.activeDestination = null;
      expect(repository.activeDestination, isNull);
    });

    test('should emit stream updates when destination changes', () async {
      final streamValues = <ActiveDestination?>[];
      final subscription = repository.watchDestinations().listen(
        streamValues.add,
      );

      // Initial value should be null
      await Future<void>.delayed(Duration.zero);
      
      repository.activeDestination = testDestination;
      await Future<void>.delayed(Duration.zero);
      
      repository.activeDestination = null;
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(streamValues, [
        null, // Initial value
        testDestination,
        null,
      ]);
    });

    test('should emit distinct values in stream', () async {
      final streamValues = <ActiveDestination?>[];
      final subscription = repository.watchDestinations().listen(
        streamValues.add,
      );

      await Future<void>.delayed(Duration.zero);
      
      // Set same value twice
      repository.activeDestination = testDestination;
      await Future<void>.delayed(Duration.zero);
      
      repository.activeDestination = testDestination;
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      // Should only emit once for duplicate value
      expect(streamValues, [
        null, // Initial value
        testDestination,
      ]);
    });

    test('should handle multiple subscribers to stream', () async {
      final stream1Values = <ActiveDestination?>[];
      final stream2Values = <ActiveDestination?>[];
      
      final subscription1 = repository.watchDestinations().listen(
        stream1Values.add,
      );
      final subscription2 = repository.watchDestinations().listen(
        stream2Values.add,
      );

      await Future<void>.delayed(Duration.zero);
      
      repository.activeDestination = testDestination;
      await Future<void>.delayed(Duration.zero);

      await subscription1.cancel();
      await subscription2.cancel();

      expect(stream1Values, [null, testDestination]);
      expect(stream2Values, [null, testDestination]);
    });

    test('should maintain separate instances', () {
      final repository1 = ActiveDestinationRepository();
      final repository2 = ActiveDestinationRepository();

      repository1.activeDestination = testDestination;
      
      expect(repository1.activeDestination, equals(testDestination));
      expect(repository2.activeDestination, isNull);
    });

    test('should handle hospital with all optional fields', () {
      const hospitalWithOptionals = Hospital(
        facilityBrandedName: 'Full Hospital',
        facilityAddress: '456 Complete Ave',
        facilityCity: 'Full City',
        facilityState: 'FC',
        facilityZip: 54321,
        latitude: 40.7128,
        longitude: -74.0060,
        county: 'Full County',
        source: 'Full Source',
        facilityPhone1: '555-0200',
        facilityPhone1Note: 'Main',
        facilityPhone2: '555-0201',
        facilityPhone2Note: 'ER',
        facilityPhone3: '555-0202',
        facilityPhone3Note: 'Cardiology',
        distanceToAsheboro: 25.5,
        pciCenter: 1,
      );

      const destinationWithOptionals = ActiveDestination(
        destination: null,
        destinationInfo: hospitalWithOptionals,
      );

      repository.activeDestination = destinationWithOptionals;
      
      expect(repository.activeDestination, equals(destinationWithOptionals));
      expect(
        repository.activeDestination?.destinationInfo.facilityPhone2,
        equals('555-0201'),
      );
    });

    test('should verify hospital is PCI center', () {
      repository.activeDestination = testDestination;
      
      expect(
        repository.activeDestination?.destinationInfo.isPci(),
        isTrue,
      );
    });

    test('should get hospital location as AppWaypoint', () {
      repository.activeDestination = testDestination;
      
      final waypoint = repository.activeDestination?.destinationInfo.location();
      
      expect(waypoint, isNotNull);
      expect(waypoint?.latitude, equals(35.7796));
      expect(waypoint?.longitude, equals(-78.6382));
    });
  });
}
