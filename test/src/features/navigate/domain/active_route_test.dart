import 'package:flutter_test/flutter_test.dart';
import 'package:google_routes_flutter/google_routes_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Mocks
class MockRoute extends Mock implements Route {}

void main() {
  group('ActiveRoute', () {
    late MockRoute mockRoute;
    const activeRouteId = '<active_step_id>';

    setUp(() {
      mockRoute = MockRoute();
    });

    test('should create with required parameters', () {
      final activeRoute = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      expect(activeRoute.activeStepId, equals(activeRouteId));
      expect(activeRoute.route, equals(mockRoute));
    });

    test('should support value equality', () {
      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      expect(activeRoute1, equals(activeRoute2));
    });

    test('should have different equality for different origins', () {
      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: 'activeRouteId',
        route: mockRoute,
      );

      expect(activeRoute1, isNot(equals(activeRoute2)));
    });

    test('should have different equality for different destinations', () {
      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: 'activeRouteId',
        route: mockRoute,
      );

      expect(activeRoute1, isNot(equals(activeRoute2)));
    });

    test('should have different equality for different destinations', () {
      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: 'activeRouteId',
        route: mockRoute,
      );

      expect(activeRoute1, isNot(equals(activeRoute2)));
    });

    test('should have different equality for different routes', () {
      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: 'activeRouteId',
        route: mockRoute,
      );

      expect(activeRoute1, isNot(equals(activeRoute2)));
    });

    test('should have different equality for different routes', () {
      final mockRoute2 = MockRoute();

      final activeRoute1 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      final activeRoute2 = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute2,
      );

      expect(activeRoute1, isNot(equals(activeRoute2)));
    });

    test('should have correct props for Equatable', () {
      final activeRoute =
          ActiveRoute(activeStepId: activeRouteId, route: mockRoute);

      expect(
        activeRoute.props,
        equals([
          mockRoute,
          activeRouteId,
        ]),
      );
    });

    test('should have string representation', () {
      final activeRoute = ActiveRoute(
        activeStepId: activeRouteId,
        route: mockRoute,
      );

      expect(activeRoute.toString(), contains('ActiveRoute'));
    });
  });
}
