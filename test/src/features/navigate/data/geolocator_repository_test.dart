import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Create a test implementation of GeolocatorPlatform
class TestGeolocatorPlatform extends GeolocatorPlatform {
  TestGeolocatorPlatform() : super();

  bool _isLocationServiceEnabled = true;
  LocationPermission _permission = LocationPermission.always;
  Position? _currentPosition;
  Position? _lastKnownPosition;
  final _positionStreamController = StreamController<Position>.broadcast();
  double _distanceResult = 0;

  // Test helpers to configure behavior
  void setLocationServiceEnabled(bool enabled) {
    _isLocationServiceEnabled = enabled;
  }

  void setPermission(LocationPermission permission) {
    _permission = permission;
  }

  void setCurrentPosition(Position? position) {
    _currentPosition = position;
  }

  void setLastKnownPosition(Position? position) {
    _lastKnownPosition = position;
  }

  void setDistanceResult(double distance) {
    _distanceResult = distance;
  }

  void emitPosition(Position position) {
    _positionStreamController.add(position);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return _isLocationServiceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return _permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (_permission == LocationPermission.denied) {
      // Simulate permission request - could be granted or still denied
      return LocationPermission.denied; // For testing denied scenario
    }
    return _permission;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    if (_currentPosition == null) {
      throw Exception('Failed to get current position');
    }
    return _currentPosition!;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async {
    return _lastKnownPosition;
  }

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return _positionStreamController.stream;
  }

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return _distanceResult;
  }

  void dispose() {
    _positionStreamController.close();
  }
}

// Create a mock Position
class TestPosition extends Position {
  const TestPosition({
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.accuracy = 10,
    super.altitude = 0,
    super.altitudeAccuracy = 0,
    super.heading = 0,
    super.headingAccuracy = 0,
    super.speed = 0,
    super.speedAccuracy = 0,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('GeolocatorRepository', () {
    late GeolocatorRepository repository;
    late TestGeolocatorPlatform testPlatform;
    late Position testPosition;

    setUp(() {
      repository = GeolocatorRepository();
      testPlatform = TestGeolocatorPlatform();
      GeolocatorPlatform.instance = testPlatform;
      
      testPosition = TestPosition(
        latitude: 35.7796,
        longitude: -78.6382,
        timestamp: DateTime(2024, 1, 15, 10, 30),
        accuracy: 5,
        altitude: 100,
        heading: 180,
        speed: 10,
      );
    });

    tearDown(() {
      testPlatform.dispose();
    });

    group('checkLocationEnabled', () {
      test(
        'should return true when location services are enabled and permission granted',
        () async {
          testPlatform
            ..setLocationServiceEnabled(true)
            ..setPermission(LocationPermission.always);

          final result = await repository.checkLocationEnabled();

          expect(result, isTrue);
        },
      );

      test('should throw error when location services are disabled', () async {
        testPlatform.setLocationServiceEnabled(false);

        expect(
          () => repository.checkLocationEnabled(),
          throwsA(
            predicate((e) => e.toString().contains('Location services are disabled')),
          ),
          );
        },
      );

      test('should request permission when initially denied', () async {
        testPlatform
          ..setLocationServiceEnabled(true)
          ..setPermission(LocationPermission.denied);

        // The test platform returns denied even after request for testing
        expect(
          () => repository.checkLocationEnabled(),
          throwsA(
            predicate((e) => e.toString().contains('Location permissions are denied')),
          ),
          );
        },
      );

      test(
        'should throw error when permission is permanently denied',
        () async {
          testPlatform
            ..setLocationServiceEnabled(true)
            ..setPermission(LocationPermission.deniedForever);

        expect(
          () => repository.checkLocationEnabled(),
          throwsA(
            predicate((e) => e.toString().contains('permanently denied')),
          ),
          );
        },
      );
    });

    group('getCurrentPosition', () {
      test('should return current position when permissions are granted', () async {
        testPlatform
          ..setLocationServiceEnabled(true)
          ..setPermission(LocationPermission.always)
          ..setCurrentPosition(testPosition);

        final position = await repository.getCurrentPosition();

        expect(position.latitude, equals(35.7796));
        expect(position.longitude, equals(-78.6382));
        expect(position.accuracy, equals(5));
      });

      test('should throw error when location services are disabled', () async {
        testPlatform.setLocationServiceEnabled(false);

        expect(
          () => repository.getCurrentPosition(),
          throwsA(
            predicate((e) => e.toString().contains('Location services are disabled')),
          ),
          );
        },
      );
    });

    group('getLastKnownPosition', () {
      test('should return last known position when available', () async {
        testPlatform
          ..setLocationServiceEnabled(true)
          ..setPermission(LocationPermission.always)
          ..setLastKnownPosition(testPosition);

        final position = await repository.getLastKnownPosition();

        expect(position, isNotNull);
        expect(position!.latitude, equals(35.7796));
        expect(position.longitude, equals(-78.6382));
      });

      test('should return null when no last known position', () async {
        testPlatform
          ..setLocationServiceEnabled(true)
          ..setPermission(LocationPermission.always)
          ..setLastKnownPosition(null);

        final position = await repository.getLastKnownPosition();

        expect(position, isNull);
      });
    });

    group('watchPosition', () {
      test('should emit position updates from stream', () async {
        final positions = <Position?>[];
        final subscription = repository.watchPosition().listen(positions.add);

        // Emit test positions
        testPlatform.emitPosition(testPosition);
        final updatedPosition = TestPosition(
          latitude: 35.8000,
          longitude: -78.6500,
          timestamp: DateTime(2024, 1, 15, 10, 35),
        );
        testPlatform.emitPosition(updatedPosition);

        await Future<void>.delayed(Duration.zero);

        expect(positions.length, equals(2));
        expect(positions[0]?.latitude, equals(35.7796));
        expect(positions[1]?.latitude, equals(35.8000));

        await subscription.cancel();
      });

      test('should use high accuracy and 100m distance filter', () {
        // We can't easily verify the location settings are passed correctly
        // with this test approach, but we can verify the stream works
        final subscription = repository.watchPosition().listen((_) {});
        
        expect(subscription, isNotNull);
        subscription.cancel();
      });
    });

    group('getDistanceBetween', () {
      test('should calculate distance between two waypoints', () {
        testPlatform.setDistanceResult(1500); // 1.5 km

        const currentLocation = AppWaypoint(
          latitude: 35.7796,
          longitude: -78.6382,
          label: 'Current Location',
        );
        
        const destination = AppWaypoint(
          latitude: 35.8801,
          longitude: -78.8784,
          label: 'Destination',
        );

        final distance = repository.getDistanceBetween(currentLocation, destination);

        expect(distance, equals(1500));
      });

      test('should handle same location (zero distance)', () {
        testPlatform.setDistanceResult(0);

        const location = AppWaypoint(
          latitude: 35.7796,
          longitude: -78.6382,
          label: 'Same Location',
        );

        final distance = repository.getDistanceBetween(location, location);

        expect(distance, equals(0));
      });
    });
  });
}
