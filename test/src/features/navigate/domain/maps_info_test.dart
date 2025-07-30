import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import 'package:nav_stemi/nav_stemi.dart';

// Mocks

// class MockPolyline extends Mock implements Polyline {}

void main() {
  group('MapsInfo', () {
    test('should create with all parameters', () {
      const marker = Marker(options: MarkerOptions(), markerId: 'marker1');
      const polyline =
          Polyline(options: PolylineOptions(), polylineId: 'polyline1');

      const mapsInfo = MapsInfo(
        origin: AppWaypoint(
          latitude: 35,
          longitude: -80,
          label: 'Origin',
        ),
        destination: AppWaypoint(
          latitude: 35.1,
          longitude: -80.1,
          label: 'Destination',
        ),
        markers: {'marker1': marker},
        polylines: {'polyline1': polyline},
      );

      expect(mapsInfo.origin?.latitude, equals(35.0));
      expect(mapsInfo.origin?.longitude, equals(-80.0));
      expect(mapsInfo.destination?.latitude, equals(35.1));
      expect(mapsInfo.destination?.longitude, equals(-80.1));
      expect(mapsInfo.markers.length, equals(1));
      expect(mapsInfo.polylines.length, equals(1));
    });

    test('should create with default empty collections', () {
      const mapsInfo = MapsInfo();

      expect(mapsInfo.origin, isNull);
      expect(mapsInfo.destination, isNull);
      expect(mapsInfo.markers, isEmpty);
      expect(mapsInfo.polylines, isEmpty);
    });

    test('should handle copyWith correctly', () {
      const origin = AppWaypoint(
        latitude: 35,
        longitude: -80,
        label: 'Origin',
      );
      const destination = AppWaypoint(
        latitude: 35.1,
        longitude: -80.1,
        label: 'Destination',
      );
      const newDestination = AppWaypoint(
        latitude: 35.2,
        longitude: -80.2,
        label: 'New Destination',
      );

      const mapsInfo = MapsInfo(
        origin: origin,
        destination: destination,
      );

      final updated = mapsInfo.copyWith(destination: newDestination);

      expect(updated.origin, equals(origin));
      expect(updated.destination, equals(newDestination));
      expect(updated.destination, isNot(equals(destination)));
    });

    test('should be immutable', () {
      const marker = Marker(options: MarkerOptions(), markerId: 'marker1');
      const mapsInfo = MapsInfo(
        markers: {'marker1': marker},
      );

      // The maps are already unmodifiable in the constructor
      expect(
        () => mapsInfo.markers['marker2'] = marker,
        throwsUnsupportedError,
      );
    });

    test('should compare equality correctly', () {
      const origin = AppWaypoint(
        latitude: 35,
        longitude: -80,
        label: 'Origin',
      );
      const destination = AppWaypoint(
        latitude: 35.1,
        longitude: -80.1,
        label: 'Destination',
      );

      const mapsInfo1 = MapsInfo(
        origin: origin,
        destination: destination,
      );

      const mapsInfo2 = MapsInfo(
        origin: origin,
        destination: destination,
      );

      const mapsInfo3 = MapsInfo(
        origin: origin,
      );

      expect(mapsInfo1, equals(mapsInfo2));
      expect(mapsInfo1, isNot(equals(mapsInfo3)));
    });

    test('should convert to and from map', () {
      const origin = AppWaypoint(
        latitude: 35,
        longitude: -80,
        label: 'Origin',
      );
      const destination = AppWaypoint(
        latitude: 35.1,
        longitude: -80.1,
        label: 'Destination',
      );

      const mapsInfo = MapsInfo(
        origin: origin,
        destination: destination,
      );

      final map = mapsInfo.toMap();
      expect(map['origin'], isNotNull);
      expect(map['destination'], isNotNull);
      expect(map['markers'], isA<Map>());
      expect(map['polylines'], isA<Map>());

      // Test fromMap
      final reconstructed = MapsInfo.fromMap(map);
      expect(reconstructed.origin?.latitude, equals(origin.latitude));
      expect(
        reconstructed.destination?.longitude,
        equals(destination.longitude),
      );
    });

    test('should handle null values in toMap and fromMap', () {
      const mapsInfo = MapsInfo();
      final map = mapsInfo.toMap();

      expect(map['origin'], isNull);
      expect(map['destination'], isNull);

      final reconstructed = MapsInfo.fromMap(map);
      expect(reconstructed.origin, isNull);
      expect(reconstructed.destination, isNull);
    });

    test('should convert to and from JSON', () {
      const mapsInfo = MapsInfo(
        origin: AppWaypoint(
          latitude: 35,
          longitude: -80,
          label: 'Origin',
        ),
      );

      final json = mapsInfo.toJson();
      expect(json, isA<String>());

      final reconstructed = MapsInfo.fromJson(json);
      expect(reconstructed.origin?.latitude, equals(35.0));
      expect(reconstructed.origin?.longitude, equals(-80.0));
    });
  });
}
