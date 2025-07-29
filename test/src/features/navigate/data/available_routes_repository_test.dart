import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('AvailableRoutesRepository', () {
    late AvailableRoutesRepository repository;
    late AvailableRoutes testRoutes;
    late Hospital testHospital;
    late AppWaypoint origin;
    late AppWaypoint destination;
    late DateTime requestedDateTime;

    setUp(() {
      repository = AvailableRoutesRepository();
      
      origin = const AppWaypoint(
        latitude: 35.7796,
        longitude: -78.6382,
        label: 'Current Location',
      );
      
      destination = const AppWaypoint(
        latitude: 35.8801,
        longitude: -78.8784,
        label: 'Test Hospital',
      );
      
      testHospital = const Hospital(
        facilityBrandedName: 'Test Medical Center',
        facilityAddress: '123 Main St',
        facilityCity: 'Test City',
        facilityState: 'TS',
        facilityZip: 12345,
        latitude: 35.8801,
        longitude: -78.8784,
        county: 'Test County',
        source: 'Test Source',
        facilityPhone1: '555-0100',
        distanceToAsheboro: 15.5,
        pciCenter: 1,
      );
      
      requestedDateTime = DateTime(2024, 1, 15, 10, 30);
      
      testRoutes = AvailableRoutes(
        origin: origin,
        destination: destination,
        destinationInfo: testHospital,
        requestedDateTime: requestedDateTime,
        // routes: null, // Google Routes SDK object - not mocked for basic tests
      );
    });

    test('should initialize with null available routes', () {
      expect(repository.getAvailableRoutes(), isNull);
    });

    test('should set and get available routes', () {
      repository.setAvailableRoutes(testRoutes);
      
      final storedRoutes = repository.getAvailableRoutes();
      expect(storedRoutes, equals(testRoutes));
      expect(storedRoutes?.origin, equals(origin));
      expect(storedRoutes?.destination, equals(destination));
      expect(storedRoutes?.destinationInfo, equals(testHospital));
      expect(storedRoutes?.requestedDateTime, equals(requestedDateTime));
      expect(storedRoutes?.routes, isNull);
    });

    test('should update available routes', () {
      repository.setAvailableRoutes(testRoutes);
      expect(repository.getAvailableRoutes(), equals(testRoutes));

      const updatedOrigin = AppWaypoint(
        latitude: 35.9000,
        longitude: -78.9000,
        label: 'New Location',
      );
      
      final updatedRoutes = AvailableRoutes(
        origin: updatedOrigin,
        destination: destination,
        destinationInfo: testHospital,
        requestedDateTime: DateTime(2024, 1, 15, 11),
        // routes: null is default
      );

      repository.setAvailableRoutes(updatedRoutes);
      
      final storedRoutes = repository.getAvailableRoutes();
      expect(storedRoutes, equals(updatedRoutes));
      expect(storedRoutes?.origin, equals(updatedOrigin));
      expect(storedRoutes?.requestedDateTime.hour, equals(11));
    });

    test('should clear available routes', () {
      repository.setAvailableRoutes(testRoutes);
      expect(repository.getAvailableRoutes(), isNotNull);

      repository.clearAvailableRoutes();
      expect(repository.getAvailableRoutes(), isNull);
    });

    test('should emit stream updates when routes change', () async {
      final streamValues = <AvailableRoutes?>[];
      final subscription = repository.watchAvailableRoutes().listen(
        streamValues.add,
      );

      // Initial value should be null
      await Future<void>.delayed(Duration.zero);
      
      repository.setAvailableRoutes(testRoutes);
      await Future<void>.delayed(Duration.zero);
      
      repository.clearAvailableRoutes();
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      expect(streamValues, [
        null, // Initial value
        testRoutes,
        null,
      ]);
    });

    test('should emit distinct values in stream', () async {
      final streamValues = <AvailableRoutes?>[];
      final subscription = repository.watchAvailableRoutes().listen(
        streamValues.add,
      );

      await Future<void>.delayed(Duration.zero);
      
      // Set same value twice
      repository.setAvailableRoutes(testRoutes);
      await Future<void>.delayed(Duration.zero);
      
      repository.setAvailableRoutes(testRoutes);
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();

      // Should only emit once for duplicate value
      expect(streamValues, [
        null, // Initial value
        testRoutes,
      ]);
    });

    test('should handle multiple subscribers to stream', () async {
      final stream1Values = <AvailableRoutes?>[];
      final stream2Values = <AvailableRoutes?>[];
      
      final subscription1 = repository.watchAvailableRoutes().listen(
        stream1Values.add,
      );
      final subscription2 = repository.watchAvailableRoutes().listen(
        stream2Values.add,
      );

      await Future<void>.delayed(Duration.zero);
      
      repository.setAvailableRoutes(testRoutes);
      await Future<void>.delayed(Duration.zero);

      await subscription1.cancel();
      await subscription2.cancel();

      expect(stream1Values, [null, testRoutes]);
      expect(stream2Values, [null, testRoutes]);
    });

    test('should maintain separate instances', () {
      final repository1 = AvailableRoutesRepository();
      final repository2 = AvailableRoutesRepository();

      repository1.setAvailableRoutes(testRoutes);
      
      expect(repository1.getAvailableRoutes(), equals(testRoutes));
      expect(repository2.getAvailableRoutes(), isNull);
    });

    test('should handle routes with different destinations', () {
      const alternateHospital = Hospital(
        facilityBrandedName: 'Alternate Medical Center',
        facilityAddress: '456 Second St',
        facilityCity: 'Other City',
        facilityState: 'OC',
        facilityZip: 54321,
        latitude: 36,
        longitude: -79,
        county: 'Other County',
        source: 'Test Source',
        facilityPhone1: '555-0200',
        distanceToAsheboro: 25.5,
        pciCenter: 0,
      );
      
      const alternateDestination = AppWaypoint(
        latitude: 36,
        longitude: -79,
        label: 'Alternate Hospital',
      );
      
      final alternateRoutes = AvailableRoutes(
        origin: origin,
        destination: alternateDestination,
        destinationInfo: alternateHospital,
        requestedDateTime: requestedDateTime,
      );

      repository.setAvailableRoutes(testRoutes);
      expect(
        repository.getAvailableRoutes()?.destinationInfo.facilityBrandedName,
        equals('Test Medical Center'),
      );

      repository.setAvailableRoutes(alternateRoutes);
      expect(
        repository.getAvailableRoutes()?.destinationInfo.facilityBrandedName,
        equals('Alternate Medical Center'),
      );
      expect(
        repository.getAvailableRoutes()?.destinationInfo.isPci(),
        isFalse,
      );
    });

    test('should validate waypoint coordinates are preserved', () {
      repository.setAvailableRoutes(testRoutes);
      
      final storedRoutes = repository.getAvailableRoutes()!;
      
      // Origin waypoint
      expect(storedRoutes.origin.latitude, equals(35.7796));
      expect(storedRoutes.origin.longitude, equals(-78.6382));
      expect(storedRoutes.origin.label, equals('Current Location'));
      
      // Destination waypoint
      expect(storedRoutes.destination.latitude, equals(35.8801));
      expect(storedRoutes.destination.longitude, equals(-78.8784));
      expect(storedRoutes.destination.label, equals('Test Hospital'));
      
      // Hospital location should match destination
      final hospitalLocation = storedRoutes.destinationInfo.location();
      expect(hospitalLocation.latitude, equals(35.8801));
      expect(hospitalLocation.longitude, equals(-78.8784));
    });

    test('should handle silent waypoints', () {
      const silentOrigin = AppWaypoint(
        latitude: 35.7796,
        longitude: -78.6382,
        label: 'Silent Location',
        isSilent: true,
      );
      
      final routesWithSilentOrigin = AvailableRoutes(
        origin: silentOrigin,
        destination: destination,
        destinationInfo: testHospital,
        requestedDateTime: requestedDateTime,
      );

      repository.setAvailableRoutes(routesWithSilentOrigin);
      
      final storedRoutes = repository.getAvailableRoutes()!;
      expect(storedRoutes.origin.isSilent, isTrue);
      expect(storedRoutes.destination.isSilent, isFalse);
    });
  });
}
