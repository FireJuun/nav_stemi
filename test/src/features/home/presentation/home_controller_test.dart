import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/src/features/home/presentation/home_controller.dart';
import 'package:nav_stemi/src/features/navigate/application/permissions_service.dart';

import '../../../../helpers/test_helpers.dart';

class MockPermissionsService extends Mock implements PermissionsService {}

void main() {
  group('HomeController', () {
    late ProviderContainer container;
    late MockPermissionsService mockPermissionsService;

    setUp(() {
      mockPermissionsService = MockPermissionsService();

      container = createContainer(
        overrides: [
          permissionsServiceProvider.overrideWithValue(mockPermissionsService),
        ],
      );
    });

    test('should have initial state as AsyncValue.data(null)', () {
      final controller = container.read(homeControllerProvider);
      expect(controller, equals(const AsyncValue<void>.data(null)));
    });

    test('should check permissions on app start', () async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenAnswer(
        (_) async => (
          areLocationsPermitted: true,
          areNotificationsPermitted: true,
        ),
      );

      final notifier = container.read(homeControllerProvider.notifier);
      final result = await notifier.checkPermissionsOnAppStart();

      expect(result.areLocationsPermitted, isTrue);
      expect(result.areNotificationsPermitted, isTrue);
      verify(() => mockPermissionsService.checkPermissionsOnAppStart())
          .called(1);
    });

    test('should handle permission check errors', () async {
      when(() => mockPermissionsService.checkPermissionsOnAppStart())
          .thenThrow(Exception('Permission error'));

      final notifier = container.read(homeControllerProvider.notifier);

      expect(
        () async => notifier.checkPermissionsOnAppStart(),
        throwsException,
      );
    });

    test('should open app settings page', () async {
      when(() => mockPermissionsService.openAppSettingsPage())
          .thenAnswer((_) async => Future.value());

      final notifier = container.read(homeControllerProvider.notifier);
      await notifier.openAppSettingsPage();

      verify(() => mockPermissionsService.openAppSettingsPage()).called(1);
    });
  });
}
